docker -H docker-host:2375 container ls -a -f label=nuget --format "{{.ID}}" | % {
    docker -H docker-host:2375 container stop $_ } | % {
    docker -H docker-host:2375 container rm $_ }