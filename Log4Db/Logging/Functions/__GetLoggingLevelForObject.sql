CREATE FUNCTION [Logging].[__GetLoggingLevelForObject] 
(
	@ObjectId Int = NULL
)
RETURNS nVarChar(13)
AS
BEGIN
   /*
    * Valid return values are:
	* ALL
	* DEBUG
	* INFO
	* WARN
	* ERROR
	* FATAL
	* NONE
	* UNINITIALIZED
    */
	
   DECLARE  @FullName nVarChar(256)
   DECLARE  @Result nVarChar(13)

   SET @FullName = [Logging].[__GetObjectName] (@ObjectId)

   IF NOT EXISTS (SELECT 1 FROM [Logging].[LogSettings] WHERE [Logging].[LogSettings].[LoggingObject] = @FullName)
      RETURN 'UNINITIALIZED'

   SELECT   @Result = COALESCE (LoggingLevel, 'INHERIT')
   FROM     [Logging].[LogSettings]
   WHERE    [Logging].[LogSettings].[LoggingObject] = @FullName

   IF (@Result = 'INHERIT' AND @FullName <> 'root')
      RETURN [Logging].[__GetLoggingLevelForObject] (0)

   -- Return the result of the function
   RETURN @Result

END
