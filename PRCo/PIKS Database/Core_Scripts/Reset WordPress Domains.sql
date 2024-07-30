USE WordPress

IF EXISTS (SELECT 'x' FROM sysobjects WHERE name = 'usp_UpdateWordPressDomainName' and type='P') 
	DROP PROCEDURE dbo.usp_UpdateWordPressDomainName
Go

CREATE PROCEDURE dbo.usp_UpdateWordPressDomainName
	@WebsiteID int,
	@NewDomainName varchar(255),
	@OldDomainName varchar(255)
AS 
BEGIN

	UPDATE wp_site
	   SET domain = @NewDomainName
	 WHERE ID = @WebsiteID

	UPDATE wp_blogs
	   SET domain = REPLACE(@NewDomainName, 'http://', '')
	 WHERE blog_id = @WebsiteID


	IF (@WebsiteID = 1) BEGIN

		UPDATE wp_options
		   SET option_value = @NewDomainName
		 WHERE option_name = 'siteurl'

		UPDATE wp_options
		   SET option_value = @NewDomainName
		 WHERE option_name = 'home'

		UPDATE wp_posts
		   SET guid =  REPLACE(guid, @OldDomainName, @NewDomainName)
		 WHERE guid LIKE '%' + @OldDomainName + '%'

		UPDATE wp_posts
		   SET post_content =  REPLACE(post_content, @OldDomainName, @NewDomainName)
		 WHERE post_content LIKE '%' + @OldDomainName + '%'

		UPDATE [wp_postmeta]
		   SET [meta_value] =  REPLACE([meta_value], @OldDomainName, @NewDomainName)
		 WHERE [meta_value] LIKE '%' + @OldDomainName + '%'
	END

	IF (@WebsiteID = 2) BEGIN

		UPDATE wp_2_options
		   SET option_value = @NewDomainName
		 WHERE option_name = 'siteurl'

		UPDATE wp_2_options
		   SET option_value = @NewDomainName
		 WHERE option_name = 'home'

		UPDATE wp_2_posts
		   SET guid =  REPLACE(guid, @OldDomainName, @NewDomainName)
		 WHERE guid LIKE '%' + @OldDomainName + '%'

		UPDATE wp_2_posts
		   SET post_content =  REPLACE(post_content, @OldDomainName, @NewDomainName)
		 WHERE post_content LIKE '%' + @OldDomainName + '%'

		UPDATE [wp_2_postmeta]
		   SET [meta_value] =  REPLACE([meta_value], @OldDomainName, @NewDomainName)
		 WHERE [meta_value] LIKE '%' + @OldDomainName + '%'
	END


	IF (@WebsiteID = 3) BEGIN

		UPDATE wp_3_options
		   SET option_value = @NewDomainName
		 WHERE option_name = 'siteurl'

		UPDATE wp_3_options
		   SET option_value = @NewDomainName
		 WHERE option_name = 'home'

		UPDATE wp_3_posts
		   SET guid =  REPLACE(guid, @OldDomainName, @NewDomainName)
		 WHERE guid LIKE '%' + @OldDomainName + '%'

		UPDATE wp_3_posts
		   SET post_content =  REPLACE(post_content, @OldDomainName, @NewDomainName)
		 WHERE post_content LIKE '%' + @OldDomainName + '%'

		UPDATE [wp_3_postmeta]
		   SET [meta_value] =  REPLACE([meta_value], @OldDomainName, @NewDomainName)
		 WHERE [meta_value] LIKE '%' + @OldDomainName + '%'
	END
END
Go

BEGIN TRANSACTION

/*
  UPDATE wp_sitemeta 
     SET meta_value = 'http://beta.producebluebook.com/'
	WHERE site_id = 1
	  AND meta_key = 'siteurl'

EXEC usp_UpdateWordPressDomainName 1, 'http://beta.producebluebook.com', 'http://qa.produce.bluebookservices.com'
EXEC usp_UpdateWordPressDomainName 2, 'http://beta.lumberbluebook.com', 'http://qa.lumber.bluebookservices.com'
EXEC usp_UpdateWordPressDomainName 3, 'http://beta.bluebookservices.com', 'http://qa.bbsi.bluebookservices.com'
*/


  UPDATE wp_sitemeta 
     SET meta_value = 'http://azqa.produce.bluebookservices.com/'
	WHERE site_id = 1
	  AND meta_key = 'siteurl'


  UPDATE wp_options 
     SET option_value = 'https://azqa.produce.bluebookservices.com/'
	WHERE option_name = 'wordpress-https_ssl_host'
	

EXEC usp_UpdateWordPressDomainName 1, 'http://azqa.produce.bluebookservices.com', 'http://www.producebluebook.com'
EXEC usp_UpdateWordPressDomainName 2, 'http://azqa.lumber.bluebookservices.com', 'http://www.lumberbluebook.com'
EXEC usp_UpdateWordPressDomainName 3, 'http://azqa.bbsi.bluebookservices.com', 'http://www.bluebookservices.com'

SELECT * FROM wp_options WHERE option_value LIKE '%producebluebook%'
SELECT * FROM wp_sitemeta WHERE meta_key = 'siteurl'
SELECT domain FROM wp_blogs
SELECT TOP 1 option_value FROM wp_options WHERE option_name LIKE  N'wck_tools'
SELECT TOP 1 option_value FROM wp_options WHERE option_name LIKE  N'widget_pages' 




/*

  UPDATE wp_sitemeta 
     SET meta_value = 'http://www.producebluebook.com/'
	WHERE site_id = 1
	  AND meta_key = 'siteurl'

EXEC usp_UpdateWordPressDomainName 1, 'http://www.producebluebook.com', 'http://beta.producebluebook.com'
EXEC usp_UpdateWordPressDomainName 2, 'http://www.lumberbluebook.com', 'http://beta.lumberbluebook.com'
EXEC usp_UpdateWordPressDomainName 3, 'http://www.bluebookservices.com', 'http://beta.bluebookservices.com'
*/

ROLLBACK

SELECT *
  FROM wp_4_options
 WHERE option_name IN ('siteurl', 'home')

SELECT *
 FROM wp_blogs		


/*
 		UPDATE wp_4_options
		   SET option_value = 'http://newqa.produce.bluebookservices.com'
		 WHERE option_name = 'siteurl'

		UPDATE wp_4_options
		   SET option_value = 'http://newqa.produce.bluebookservices.com'
		 WHERE option_name = 'home'

		 UPDATE wp_blogs
		    SET domain = 'newqa.produce.bluebookservices.com'
		  WHERE blog_id=4
*/