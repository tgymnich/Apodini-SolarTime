# Apodini-SolarTime

## Endpoints

| Endpoint | Description | Optional Query Parameters |
|-|-|-|
| `/v1` | returns the solar time based on the location of your IP address  | `latitude`, `longitude`, `time` |
| `/v1/{location}` | returns the solar time based on the location passed in the path parameter | `time` |

## Example

```
curl --request GET http://localhost:8080/v1/Munich
```
returns
```
{
  "data" : {
    "currentDeclination" : 14.953388755535467,
    "sunset" : "2021-02-08T16:24:51.057Z",
    "hoursOfSunlight" : 9.8667992055416107,
    "zenith" : "2021-02-08T11:28:50.818Z",
    "sunrise" : "2021-02-08T06:32:50.580Z"
  },
  "_links" : {
    "self" : "http://127.0.0.1:8080/v1/Munich"
  }
}

