CREATE PROCEDURE [Logging].[SetLoggingLevelForObject]
(
   @ObjectId Integer = NULL,
   @ObjectName nVarChar(257) = NULL,
   @NewLevel nVarChar(13)
)
AS BEGIN
   IF @ObjectName IS NULL OR @ObjectName = ''
      SET @ObjectName = [Logging].[__GetObjectName] (@ObjectId)

   UPDATE   [Logging].[LogSettings]
   SET      [Logging].[LogSettings].[LoggingLevel] = @NewLevel
   WHERE    [Logging].[LogSettings].[LoggingObject] = @ObjectName

   IF @@ROWCOUNT = 0
      INSERT INTO [Logging].[LogSettings] ([LoggingObject], [LoggingLevel]) VALUES (@ObjectName, @NewLevel)
END
