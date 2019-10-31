FROM mcr.microsoft.com/dotnet/core/sdk:2.2 AS build

WORKDIR /build
COPY . .
RUN dotnet publish -o /build/output

FROM mcr.microsoft.com/dotnet/core/runtime:2.2

WORKDIR /app
COPY --from=build /build/output .
ENTRYPOINT [ "dotnet", "DiskIO.dll" ]