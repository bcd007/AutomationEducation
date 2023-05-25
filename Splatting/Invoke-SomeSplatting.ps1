#
# Splatting!!
#

$hashTableforADAccountSearch = @{
  Filter = 'GivenName -eq "Robert"'
  Properties = 'whenCreated','telephoneNumber','Title'
  Server = 'am.lilly.com'
}

get-aduser @hashTableforADAccountSearch
