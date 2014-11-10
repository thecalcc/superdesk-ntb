Feature: Packages

    @auth
    Scenario: Empty packages list
        Given empty "packages"
        When we get "/packages"
        Then we get list with 0 items

    @auth
    Scenario: Create new package without associated content
        Given empty "packages"
        When we post to "/packages"
        """
        {
        "guid": "tag:example.com,0000:newsml_BRE9A605",
        "associations": []
        }
        """
        Then we get error 400
        """
        {
            "_error": {"code": 400, "message": "Insertion failure: 1 document(s) contain(s) error(s)"},
            "_issues": {"associations": {"minlength": 1}},
            "_status": "ERR"
        }
        """

    @auth
    Scenario: Create new package with text content
        Given empty "packages"
        When we post to "archive"
	    """
        [{"headline": "test"}]
	    """
        When we post to "/packages" with success
        """
        {
            "associations": [
                {
                    "headline": "test package with text",
                    "itemRef": "/archive/#ARCHIVE_ID#",
                    "slugline": "awesome article"
                }
            ],
            "guid": "tag:example.com,0000:newsml_BRE9A605"
        }
        """
        And we get "/packages"
        Then we get list with 1 items
            """
            {
                "_items": [
                    {
                        "associations": [
                            {
                                "guid": "#ARCHIVE_ID#",
                                "headline": "test package with text",
                                "itemRef": "/archive/#ARCHIVE_ID#",
                                "slugline": "awesome article",
                                "type": "text"
                            }
                        ],
                        "guid": "tag:example.com,0000:newsml_BRE9A605",
                        "type": "composite"
                    }
                ]
            }
            """

    @auth
    Scenario: Create new package with image content
        Given empty "packages"
        When we upload a file "bike.jpg" to "archive_media"
        When we post to "/packages" with success
        """
        {
            "associations": [
                {
                    "headline": "test package with pic",
                    "itemRef": "/archive/#ARCHIVE_MEDIA_ID#",
                    "slugline": "awesome picture"
                }
            ]
        }
        """
        And we get "/packages"
        Then we get list with 1 items
            """
            {
                "_items": [
                    {
                        "associations": [
                            {
                                "guid": "#ARCHIVE_MEDIA_ID#",
                                "headline": "test package with pic",
                                "itemRef": "/archive/#ARCHIVE_MEDIA_ID#",
                                "slugline": "awesome picture",
                                "type": "picture"
                            }
                        ],
                        "type": "composite"
                    }
                ]
            }
            """

    @auth
    Scenario: Create package with image and text
        Given empty "packages"
        When we upload a file "bike.jpg" to "archive_media"
        When we post to "archive"
	    """
        [{"headline": "test"}]
	    """
        When we post to "/packages" with success
        """
        {
            "associations": [
                {
                    "headline": "test package with pic",
                    "itemRef": "/archive/#ARCHIVE_MEDIA_ID#",
                    "slugline": "awesome picture"
                },
                {
                    "headline": "test package with text",
                    "itemRef": "/archive/#ARCHIVE_ID#",
                    "slugline": "awesome article"
                }
            ]
        }
        """
        And we get "/packages"
        Then we get list with 1 items
            """
            {
                "_items": [
                    {
                        "associations": [
                            {
                                "guid": "#ARCHIVE_MEDIA_ID#",
                                "headline": "test package with pic",
                                "itemRef": "/archive/#ARCHIVE_MEDIA_ID#",
                                "slugline": "awesome picture",
                                "type": "picture"
                            },
                            {
                                "headline": "test package with text",
                                "itemRef": "/archive/#ARCHIVE_ID#",
                                "slugline": "awesome article",
                                "type": "text"
                            }
                        ],
                        "type": "composite"
                    }
                ]
            }
            """

    @auth
    Scenario: Retrieve created package
        Given empty "packages"
        When we post to "archive"
	    """
        [{"headline": "test"}]
	    """
        When we post to "/packages" with success
        """
        {
            "associations": [
                {
                    "headline": "test package with text",
                    "itemRef": "/archive/#ARCHIVE_ID#",
                    "slugline": "awesome article"
                }
            ]
        }
        """
        Then we get new resource
        """
        {
            "associations": [
                {
                    "headline": "test package with text",
                    "itemRef": "/archive/#ARCHIVE_ID#",
                    "slugline": "awesome article"
                }
            ],
            "type": "composite"
        }
        """
        And we get latest
        When we get "/archive"
        Then we get list with 2 items
            """
            {
                "_items": [
                    {
                        "guid": "#ARCHIVE_ID#",
                        "headline": "test",
                        "linked_in_packages": [{"package": "#PACKAGES_ID#"}],
                        "type": "text"
                    },
                    {
                        "associations": [
                            {
                                "headline": "test package with text",
                                "itemRef": "/archive/#ARCHIVE_ID#",
                                "slugline": "awesome article"
                            }
                        ],
                        "type": "composite"
                    }
                ]
            }
            """
        
    @auth
    Scenario: Patch created package
        Given empty "packages"
        When we post to "archive"
	    """
        [{"headline": "test"}]
	    """
        When we upload a file "bike.jpg" to "archive_media"
        When we post to "/packages" with success
        """
        {
            "associations": [
                {
                    "headline": "test package with text",
                    "itemRef": "/archive/#ARCHIVE_ID#",
                    "slugline": "awesome article"
                }
            ]
        }
        """
        And we patch latest
        """
        {
            "associations": [
                {
                    "headline": "test package with pic",
                    "itemRef": "/archive/#ARCHIVE_MEDIA_ID#",
                    "slugline": "awesome picture"
                },
                {
                    "headline": "test package with text",
                    "itemRef": "/archive/#ARCHIVE_ID#",
                    "slugline": "awesome article"
                }
            ]
        }
        """
        Then we get existing resource
        """
        {
            "associations": [
                {
                    "guid": "#ARCHIVE_MEDIA_ID#",
                    "headline": "test package with pic",
                    "itemRef": "/archive/#ARCHIVE_MEDIA_ID#",
                    "slugline": "awesome picture",
                    "type": "picture"
                },
                {
                    "headline": "test package with text",
                    "itemRef": "/archive/#ARCHIVE_ID#",
                    "slugline": "awesome article",
                    "type": "text"
                }
            ],
            "type": "composite"
        }
        """

    @auth
    Scenario: Delete created package
        Given empty "packages"
        When we post to "archive"
	    """
        [{"headline": "test"}]
	    """
        When we post to "/packages" with success
        """
        {
            "associations": [
                {
                    "headline": "test package with text",
                    "itemRef": "/archive/#ARCHIVE_ID#",
                    "slugline": "awesome article"
                }
            ]
        }
        """
        Then we get new resource
        """
        {
            "associations": [
                {
                    "headline": "test package with text",
                    "itemRef": "/archive/#ARCHIVE_ID#",
                    "slugline": "awesome article"
                }
            ],
            "type": "composite"
        }
        """
        When we delete latest
        Then we get deleted response
        When we get "/archive"
        Then we get list with 1 items
            """
            {
                "_items": [
                    {
                    "headline": "test",
                    "linked_in_packages": [],
                    "guid": "#ARCHIVE_ID#",
                    "type": "text"
                    }
                ]
            }
            """
