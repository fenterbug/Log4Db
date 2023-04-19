CREATE PROCEDURE [Logging].[__InitializeLoggingForObject] (
   @ObjectId Int
)
AS BEGIN
-- Always initialize for root. It won't create duplicates but it does ensure that the setting exists.
EXEC [Logging].[SetLoggingLevelForObject]
   0
 , @NewLevel = 'NONE'

EXEC [Logging].[SetLoggingLevelForObject]
   @ObjectId = @ObjectId
 , @NewLevel = 'INHERIT'
END
