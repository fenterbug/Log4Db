CREATE FUNCTION [Logging].[__IsLoggingLevelEnabledForObject] 
(
	@LoggingLevel nVarChar(10),
	@ObjectId Int
)
RETURNS nVarChar(13)
AS
BEGIN
   /*
    * Valid return values are:
	* YES
	* NO
	* UNINITIALIZED
    */
	
   DECLARE  @FullName nVarChar(256) = [Logging].[__GetObjectName] (@ObjectId)
   DECLARE  @ObjectLoggingLevel nVarChar(13) = [Logging].[__GetLoggingLevelForObject] (@ObjectId)

   IF @objectLoggingLevel = 'UNINITIALIZED'
      RETURN 'UNINITIALIZED'

   DECLARE  @ObjectLevelValue Int = [Logging].[__GetLevelValue] (@ObjectLoggingLevel)
   DECLARE  @RequestedValue Int = [Logging].[__GetLevelValue] (@LoggingLevel)

   IF @ObjectLevelValue <= @RequestedValue
      RETURN 'YES'

   -- Return the result of the function
   RETURN 'NO'
END
