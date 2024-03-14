/* Name: ATI_DetailPageUrlLocatorInterface
Description : Interface to get detail page URL for different objects
Author : TAVANT
History:
VERSION     AUTHOR                 DATE                          UserStory/Req#
1.0 -     Tavant                01/12/2020                       20598                      
*/
public interface ATI_DetailPageUrlLocatorInterface {
	//getURL -> interface method which will be overriden by other classes
	String getURL(String recordId);
}