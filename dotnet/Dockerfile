FROM mcr.microsoft.com/dotnet/core/aspnet:2.2.6 AS runtime
MAINTAINER DT
WORKDIR /app
RUN chmod -R 777 .
ENTRYPOINT ["dotnet","SpiderLotto.dll","-s"]
