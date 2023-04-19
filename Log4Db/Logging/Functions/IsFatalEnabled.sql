CREATE FUNCTION [Logging].[IsFatalEnabled] 
(
   @ObjectId Integer
)
RETURNS nVarChar(13)
AS
BEGIN
   RETURN [Logging].[__IsLoggingLevelEnabledForObject] ('FATAL', @ObjectId)
END
