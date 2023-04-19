CREATE PROCEDURE [Logging].[Error] (
   @ObjectId Int = NULL,
   @ObjectName sysname = NULL,
   @Message nVarChar(MAX) = NULL,
   @UseError Int = NULL
) AS BEGIN
EXEC [Logging].[__DoLog] @ObjectId = @ObjectId, @ObjectName = @ObjectName, @UseError = @UseError, @Message = @Message, @LogLevel = 'ERROR'
END
