CREATE FUNCTION [Logging].[IsInfoEnabled] 
(
   @ObjectId Integer
)
RETURNS nVarChar(13)
AS
BEGIN
   RETURN [Logging].[__IsLoggingLevelEnabledForObject] ('INFO', @ObjectId)
END
