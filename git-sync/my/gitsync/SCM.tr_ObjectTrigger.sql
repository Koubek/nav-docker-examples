SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'SCM.ObjectIUD' AND type = 'TR')
BEGIN
    DROP TRIGGER [dbo].[SCM.ObjectIUD]
END
GO

CREATE TRIGGER [dbo].[SCM.ObjectIUD]
ON [dbo].[Object]
AFTER INSERT, UPDATE, DELETE
AS BEGIN

    BEGIN TRY
		DECLARE 
			@Count AS INT,
			@ObjId AS INT,
			@ObjType AS INT,
			@ObjIdDel AS INT,
			@ObjTypeDel AS INT,
			@ObjName AS VARCHAR(30),
			@ObjVList AS VARCHAR(80),
			@ObjMod AS TINYINT,
			@ObjCompiled AS TINYINT,
			@ObjDate AS DATETIME,
			@ObjTime AS DATETIME,
			@ObjSidString AS VARCHAR(120),
			@CurrOperDT AS DATETIME,
			@BlobContent AS VARBINARY(MAX),
			/*
			@TriggerAction = 1 => INSERT
			@TriggerAction = 2 => UPDATE
			@TriggerAction = 3 => DELETE
			*/
			@TriggerAction AS TINYINT = 0,
			@ObjRenumbered AS BIT = 0,
			@ErrorMessage NVARCHAR(4000),
			@ErrorSeverity INT,
			@ErrorState INT;
			
		SET @CurrOperDT	= GETUTCDATE();
				
		-- Detect which action has been triggered
		-- Set Action to Insert by default.
		SET @TriggerAction = 1;
		IF EXISTS(SELECT * FROM deleted)
		BEGIN
			SET @TriggerAction = 
				CASE
					WHEN EXISTS(SELECT * FROM inserted) THEN 2 -- Set Action to Updated.
					ELSE 3 -- Set Action to Deleted.
				END;
			SELECT @ObjIdDel = OD.[ID], @ObjTypeDel = OD.[Type] FROM deleted AS OD;
		END	ELSE BEGIN
			IF NOT EXISTS(SELECT * FROM inserted) RETURN; -- Nothing updated or inserted.
		END;

		IF (@TriggerAction BETWEEN 1 AND 2) BEGIN
			-- INSERT/UPDATE
			SELECT 
				@ObjId = CO.ID, 
				@ObjType = CO.[Type],
				@ObjName = CO.Name,
				@ObjVList = CO.[Version List],
				@ObjMod = CO.Modified,
				@ObjCompiled = CO.Compiled,
				@ObjDate = CO.Compiled,
				@ObjDate = CO.[Date],
				@ObjTime = CO.[Time]
			FROM inserted AS CO;
			
			IF (@ObjType = 0)
				-- We will skip DataTable
				RETURN;
			
			SELECT 
				@BlobContent = O2.[BLOB Reference]
			FROM inserted AS CO2
			JOIN [dbo].[Object] AS O2 ON
			(CO2.[Type] = O2.[Type]) AND (CO2.[ID] = O2.[ID])
			
		END ELSE BEGIN
			-- DELETE
			SELECT 
				@ObjId = DO.ID, 
				@ObjType = DO.[Type],
				@ObjName = DO.Name,
				@ObjVList = DO.[Version List],
				@ObjMod = DO.Modified,
				@ObjCompiled = DO.Compiled,
				@ObjDate = DO.[Date],
				@ObjTime = DO.[Time]
			FROM deleted AS DO;
			
			IF (@ObjType = 0)
				-- We will skip DataTable
				RETURN;
				
			SELECT 
				@BlobContent = O2.[BLOB Reference]
			FROM deleted AS DO2
			JOIN [dbo].[Object] AS O2 ON
			(DO2.[Type] = O2.[Type]) AND (DO2.[ID] = O2.[ID]);
			
		END;
						
		IF (@TriggerAction = 2) AND (@ObjId != @ObjIdDel) BEGIN
			SET @ObjRenumbered = 1;		
		END;	
		
		EXEC [dbo].[SCM.InsertToObjLog]
			@ObjType = @ObjType,
			@ObjId = @ObjId,
			@ObjName = @ObjName,
			@ObjVList = @ObjVList,
			@ObjMod = @ObjMod,
			@ObjCompiled = @ObjCompiled,
			@ObjDate = @ObjDate,
			@ObjTime = @ObjTime,
			@CurrOperDT = @CurrOperDT,
			@BlobContent = @BlobContent,
			@TriggerAction = @TriggerAction
			;
		
		IF (@ObjRenumbered = 1) BEGIN
			EXEC [dbo].[SCM.InsertToObjLog]
				@ObjType = @ObjType,
				@ObjId = @ObjIdDel,
				@ObjName = @ObjName,
				@ObjVList = @ObjVList,
				@ObjMod = @ObjMod,
				@ObjCompiled = @ObjCompiled,
				@ObjDate = @ObjDate,
				@ObjTime = @ObjTime,
				@CurrOperDT = @CurrOperDT,
				@BlobContent = @BlobContent,
				@TriggerAction = 3	-- DELETE
				;
		END;		
				
	END TRY
	BEGIN CATCH

		SELECT 
			@ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE();
			
		SET @ErrorMessage = 
			CHAR(13) +  CHAR(13) + 
			'===============================================' +
			CHAR(13) +
			@ErrorMessage +
			CHAR(13) +
			'===============================================' +
			CHAR(13);
		
		RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
		
	END CATCH
END;


