#!/bin/bash

# act --secret-file ./local_test/my.secrets -j test
go test ./zpa -v -parallel 1 -run='TestAccDataSourceAuthSettingsUrls_Basic' -timeout 60m
# git branch -d import-policy-by-name
# git push origin --delete import-policy-by-name
# git branch -d get-all-data-sources
# git push origin --delete get-all-data-sources
# git branch -d fix-secret-bad-char
# git push origin --delete fix-secret-bad-char
# git branch -d validate-lat-longitude
# git push origin --delete validate-lat-longitude

export ZSCANNER_CLIENT_ID="HT0rYTTnIxZjHi1B8pxoewhwr6HsIiWS"
export ZSCANNER_CLIENT_SECRET="WSEvjnBwIiOqgXiWNT7dG1pm99rWYD6GbfMlSk90-4e9X3OdA6Se39Z0wmGaOitR"
