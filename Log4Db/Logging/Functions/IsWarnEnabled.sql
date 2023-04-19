CREATE FUNCTION [Logging].[IsWarnEnabled] 
(
   @ObjectId Integer
)
RETURNS nVarChar(13)
AS
BEGIN
   RETURN [Logging].[__IsLoggingLevelEnabledForObject] ('WARN', @ObjectId)
END
