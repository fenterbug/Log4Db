CREATE FUNCTION [Logging].[IsDebugEnabled] 
(
   @ObjectId Integer
)
RETURNS nVarChar(13)
AS
BEGIN
   RETURN [Logging].[__IsLoggingLevelEnabledForObject] ('DEBUG', @ObjectId)
END
