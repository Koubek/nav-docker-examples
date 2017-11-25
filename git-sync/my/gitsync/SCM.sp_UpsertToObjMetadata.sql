SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- At first delete existing procedure
IF EXISTS (SELECT * FROM sysobjects WHERE name = 'SCM.UpsertToObjMetadata' AND type = 'P')
BEGIN
    DROP PROCEDURE [dbo].[SCM.UpsertToObjMetadata];
END;
GO

-- Create it again
CREATE PROCEDURE [dbo].[SCM.UpsertToObjMetadata] 
	@ObjType AS INT,
	@ObjId AS INT,
	@Filename AS NVARCHAR(50),
	@TxtFileHash AS NVARCHAR(32)
AS BEGIN

	BEGIN TRY
	
		DECLARE
			@Count AS INT,
			@LockingActive AS BIT = 0,
			@ErrorMessage NVARCHAR(4000),
			@ErrorSeverity INT,
			@ErrorState INT;
						
		-- Exists object log register (record in the [SCM.ObjectMetadata] table)?
		SELECT @Count = COUNT(*) FROM [dbo].[SCM.ObjectMetadata] AS OM 
			WHERE (OM.[Object ID] = @ObjId) AND (OM.[Object Type] = @ObjType);
			
		IF (@Count > 0) BEGIN		
			
			UPDATE [dbo].[SCM.ObjectLog] SET
				[Last Block DateTime] = @CurrOperDT,
				[Object Last Name] = @ObjName,
				[Object Last Version List] = @ObjVList,
				[Object Last Object Date] = @ObjDate,
				[Object Last Object Time] = @ObjTime,
				[Last Action] = @TriggerAction,
				[Transaction GUID] = NEWID()
			WHERE
				([Object ID] = @ObjId) AND ([Object Type] = @ObjType);
				
		END ELSE BEGIN

			INSERT INTO [dbo].[SCM.ObjectMetadata] (
						[Object Type], 
						[Object ID], 
						[Initial Block DateTime], 
						[Last Block DateTime],
						[Object Last Name],
						[Object Last Version List],
						[Object Last Object Date],
						[Object Last Object Time],
						[Last Action],
						[Action GUID])
					VALUES (
						@ObjType, 
						@ObjId, 
						@CurrOperDT, 
						@CurrOperDT,
						@ObjName,
						@ObjVList,
						@ObjDate,
						@ObjTime,
						@TriggerAction,
						NEWID());
		END;
		
		
		/*
		INSERT INTO [dbo].[SCM.ObjectLogDetail] (
				[Object Type], 
				[Object ID], 
				[Modification DateTime], 
				[Object BLOB Content], 
				[Operation Type],
				[Object Name],
				[Object Version List],
				[Object Modified],
				[Object Compiled],
				[Object Date],
				[Object Time])
			VALUES (
				@ObjType, 
				@ObjId, 
				@CurrOperDT, 
				@BlobContent, 
				@TriggerAction,
				@ObjName,
				@ObjVList,
				@ObjMod,
				@ObjCompiled,
				@ObjDate,
				@ObjTime);		
		*/
				
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
	END CATCH;
END;

GO