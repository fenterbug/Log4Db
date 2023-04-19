CREATE PROCEDURE [Logging].[ExampleUsage]
AS
	SET NOCOUNT ON

	-- A simple logging statement
	EXEC [Logging].[Debug] @ObjectName = 'ExampleUsage', @Message = 'This is a simple debug statement.'


	-- This can introduce a performance gain if it takes a lot of work to build your message.
	IF ('Yes' = [Logging].[IsDebugEnabled] ('ExampleUsage')) BEGIN
		DECLARE @CurrentMessage nVarChar(max)
		SET @CurrentMessage = FORMATMESSAGE ('Fix the error ''%1''', 'This error needs to be fixed.')
		SET @CurrentMessage = FORMATMESSAGE (@CurrentMessage + ' in procedure ''%1''!', 'ExampleUsage')
		EXEC  [Logging].[Debug] @ObjectName = 'ExampleUsage', @Message = @CurrentMessage
	END


	-- Basic error logging.
	BEGIN TRY
		SELECT 1/0
	END TRY
	BEGIN CATCH
		EXEC [Logging].[Error] @ObjectName = 'ExampleUsage', @UseError = 1
		;THROW -- or don't ;THROW depending on whether or not you can gracefully deal with the error
	END CATCH


	-- Better error logging?
	BEGIN TRY
		BEGIN TRANSACTION
			SELECT 1/0
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF (XACT_STATE()) = -1 BEGIN -- Probably the most common case, so do it first (minor optimization)
			EXEC [Logging].[Error] @ObjectName = 'ExampleUsage', @UseError = 1
			ROLLBACK TRANSACTION
			;THROW
		END

		IF (XACT_STATE()) = 1 BEGIN
			EXEC [Logging].[Warn] @ObjectName = 'ExampleUsage', @UseError = 1
			COMMIT TRANSACTION
		END

		IF (XACT_STATE()) = 0 BEGIN
			EXEC [Logging].[Warn] @ObjectName = 'ExampleUsage', @UseError = 1
			-- There is no transaction to commit or rollback
		END
	END CATCH
RETURN 0
