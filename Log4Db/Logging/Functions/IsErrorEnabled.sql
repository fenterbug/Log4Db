CREATE FUNCTION [Logging].[IsErrorEnabled] 
(
   @ObjectId Integer
)
RETURNS nVarChar(13)
AS
BEGIN
   RETURN [Logging].[__IsLoggingLevelEnabledForObject] ('ERROR', @ObjectId)
END
