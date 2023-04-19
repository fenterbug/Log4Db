CREATE FUNCTION Logging.__GetLevelValue 
(
   @LoggingLevel nVarChar(13)
)
RETURNS Integer
AS
BEGIN
   DECLARE @ResultVar Integer

   SET @ResultVar = CASE @LoggingLevel
      WHEN 'ALL' THEN 0
      WHEN 'DEBUG' THEN 1
      WHEN 'INFO' THEN 2
      WHEN 'WARN' THEN 3
      WHEN 'ERROR' THEN 4
      WHEN 'FATAL' THEN 5
      WHEN 'NONE' THEN 99
      ELSE 99
   END

   RETURN @ResultVar
END
