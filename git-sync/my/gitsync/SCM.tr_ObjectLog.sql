SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF EXISTS (SELECT name FROM sysobjects WHERE name = 'SCM.ObjectLogIUD' AND type = 'TR')
BEGIN
    DROP TRIGGER [dbo].[SCM.ObjectLogIUD]
END
GO

CREATE TRIGGER [dbo].[SCM.ObjectLogIUD]
ON [dbo].[SCM.ObjectLog]
AFTER INSERT, UPDATE, DELETE
AS BEGIN		
	
	BEGIN TRY
	
		DECLARE
			/*
			@TriggerAction = 1 => INSERT
			@TriggerAction = 2 => UPDATE
			@TriggerAction = 3 => DELETE
			*/
			@TriggerAction AS TINYINT = 0,
			@DeletePermited AS BIT = 0,
			@ErrorMessage NVARCHAR(4000),
			@ErrorSeverity INT,
			@ErrorState INT;
	
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
		END	ELSE BEGIN
			IF NOT EXISTS(SELECT * FROM inserted) RETURN; -- Nothing updated or inserted.
		END;
		
		IF (@TriggerAction BETWEEN 1 AND 2) BEGIN
			-- INSERT, UPDATE => Right now exit
			RETURN;
		END ELSE BEGIN
			-- DELETE
			SELECT @DeletePermited = OD.[Delete Permited] FROM deleted AS OD;
			
			IF (@DeletePermited = 0) BEGIN
				SET @ErrorMessage = 'You can`t delete the register of the table OVC Object Log directly';
				RAISERROR(@ErrorMessage, 16, 10);
			END;
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