# DefaultAPI

All URIs are relative to *http://localhost:8080*

Method | HTTP request | Description
------------- | ------------- | -------------
[**djsBinDelete**](DefaultAPI.md#djsbindelete) | **DELETE** /djs/bin | Remove from DJ bin
[**djsBinGet**](DefaultAPI.md#djsbinget) | **GET** /djs/bin | Get DJ bin
[**djsBinPost**](DefaultAPI.md#djsbinpost) | **POST** /djs/bin | Add to DJ bin
[**djsGet**](DefaultAPI.md#djsget) | **GET** /djs | Get DJ information
[**djsPlaylistsGet**](DefaultAPI.md#djsplaylistsget) | **GET** /djs/playlists | Get playlists for DJ
[**djsRegisterPatch**](DefaultAPI.md#djsregisterpatch) | **PATCH** /djs/register | Update DJ information
[**djsRegisterPost**](DefaultAPI.md#djsregisterpost) | **POST** /djs/register | Register a new DJ
[**flowsheetDelete**](DefaultAPI.md#flowsheetdelete) | **DELETE** /flowsheet | Delete flowsheet entry
[**flowsheetDjsOnAirGet**](DefaultAPI.md#flowsheetdjsonairget) | **GET** /flowsheet/djs-on-air | Get list of DJs currently on air
[**flowsheetEndPost**](DefaultAPI.md#flowsheetendpost) | **POST** /flowsheet/end | End or leave a show
[**flowsheetGet**](DefaultAPI.md#flowsheetget) | **GET** /flowsheet | Get flowsheet entries
[**flowsheetJoinPost**](DefaultAPI.md#flowsheetjoinpost) | **POST** /flowsheet/join | Start or join a show
[**flowsheetLatestGet**](DefaultAPI.md#flowsheetlatestget) | **GET** /flowsheet/latest | Get the most recent flowsheet entry
[**flowsheetOnAirGet**](DefaultAPI.md#flowsheetonairget) | **GET** /flowsheet/on-air | Get on-air status for DJ
[**flowsheetPatch**](DefaultAPI.md#flowsheetpatch) | **PATCH** /flowsheet | Update flowsheet entry
[**flowsheetPlayOrderPatch**](DefaultAPI.md#flowsheetplayorderpatch) | **PATCH** /flowsheet/play-order | Update the play order of a flowsheet entry
[**flowsheetPlaylistGet**](DefaultAPI.md#flowsheetplaylistget) | **GET** /flowsheet/playlist | Get complete playlist for a show
[**flowsheetPost**](DefaultAPI.md#flowsheetpost) | **POST** /flowsheet | Add entry to flowsheet
[**libraryArtistsPost**](DefaultAPI.md#libraryartistspost) | **POST** /library/artists | Add new artist
[**libraryFormatsGet**](DefaultAPI.md#libraryformatsget) | **GET** /library/formats | Get format list
[**libraryFormatsPost**](DefaultAPI.md#libraryformatspost) | **POST** /library/formats | Add new format
[**libraryGenresGet**](DefaultAPI.md#librarygenresget) | **GET** /library/genres | Get genre list
[**libraryGenresPost**](DefaultAPI.md#librarygenrespost) | **POST** /library/genres | Add new genre
[**libraryGet**](DefaultAPI.md#libraryget) | **GET** /library | Search for album
[**libraryInfoGet**](DefaultAPI.md#libraryinfoget) | **GET** /library/info | Get album information
[**libraryPost**](DefaultAPI.md#librarypost) | **POST** /library | Add new album
[**libraryRotationGet**](DefaultAPI.md#libraryrotationget) | **GET** /library/rotation | Get rotation list
[**libraryRotationPatch**](DefaultAPI.md#libraryrotationpatch) | **PATCH** /library/rotation | Set rotation removal date
[**libraryRotationPost**](DefaultAPI.md#libraryrotationpost) | **POST** /library/rotation | Add new rotation
[**libraryTracksGet**](DefaultAPI.md#librarytracksget) | **GET** /library/tracks | Search for tracks
[**metadataAlbumGet**](DefaultAPI.md#metadataalbumget) | **GET** /metadata/album | Get album metadata
[**metadataArtistGet**](DefaultAPI.md#metadataartistget) | **GET** /metadata/artist | Get artist metadata
[**requestsGet**](DefaultAPI.md#requestsget) | **GET** /requests | Get song requests
[**requestsIdPatch**](DefaultAPI.md#requestsidpatch) | **PATCH** /requests/{id} | Update request status
[**requestsPost**](DefaultAPI.md#requestspost) | **POST** /requests | Submit a song request
[**scheduleGet**](DefaultAPI.md#scheduleget) | **GET** /schedule | Get schedule
[**schedulePost**](DefaultAPI.md#schedulepost) | **POST** /schedule | Add to schedule
[**scheduleShiftsGet**](DefaultAPI.md#scheduleshiftsget) | **GET** /schedule/shifts | Get schedule shifts
[**scheduleSpecialtyGet**](DefaultAPI.md#schedulespecialtyget) | **GET** /schedule/specialty | Get specialty shows


# **djsBinDelete**
```swift
    open class func djsBinDelete(djsBinPostRequest: DjsBinPostRequest, completion: @escaping (_ data: Void?, _ error: Error?) -> Void)
```

Remove from DJ bin

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI

let djsBinPostRequest = _djs_bin_post_request(djId: 123, albumId: 123, trackTitle: "trackTitle_example") // DjsBinPostRequest | 

// Remove from DJ bin
DefaultAPI.djsBinDelete(djsBinPostRequest: djsBinPostRequest) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **djsBinPostRequest** | [**DjsBinPostRequest**](DjsBinPostRequest.md) |  | 

### Return type

Void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **djsBinGet**
```swift
    open class func djsBinGet(djId: Int? = nil, completion: @escaping (_ data: DJBinResponse?, _ error: Error?) -> Void)
```

Get DJ bin

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI

let djId = 987 // Int |  (optional)

// Get DJ bin
DefaultAPI.djsBinGet(djId: djId) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **djId** | **Int** |  | [optional] 

### Return type

[**DJBinResponse**](DJBinResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **djsBinPost**
```swift
    open class func djsBinPost(djsBinPostRequest: DjsBinPostRequest, completion: @escaping (_ data: BinEntry?, _ error: Error?) -> Void)
```

Add to DJ bin

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI

let djsBinPostRequest = _djs_bin_post_request(djId: 123, albumId: 123, trackTitle: "trackTitle_example") // DjsBinPostRequest | 

// Add to DJ bin
DefaultAPI.djsBinPost(djsBinPostRequest: djsBinPostRequest) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **djsBinPostRequest** | [**DjsBinPostRequest**](DjsBinPostRequest.md) |  | 

### Return type

[**BinEntry**](BinEntry.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **djsGet**
```swift
    open class func djsGet(djId: Int? = nil, cognitoUserName: String? = nil, completion: @escaping (_ data: DjsGet200Response?, _ error: Error?) -> Void)
```

Get DJ information

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI

let djId = 987 // Int |  (optional)
let cognitoUserName = "cognitoUserName_example" // String |  (optional)

// Get DJ information
DefaultAPI.djsGet(djId: djId, cognitoUserName: cognitoUserName) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **djId** | **Int** |  | [optional] 
 **cognitoUserName** | **String** |  | [optional] 

### Return type

[**DjsGet200Response**](DjsGet200Response.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **djsPlaylistsGet**
```swift
    open class func djsPlaylistsGet(completion: @escaping (_ data: [ShowPeek]?, _ error: Error?) -> Void)
```

Get playlists for DJ

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI


// Get playlists for DJ
DefaultAPI.djsPlaylistsGet() { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**[ShowPeek]**](ShowPeek.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **djsRegisterPatch**
```swift
    open class func djsRegisterPatch(newDJ: NewDJ, completion: @escaping (_ data: DJ?, _ error: Error?) -> Void)
```

Update DJ information

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI

let newDJ = NewDJ(cognitoUserName: "cognitoUserName_example", realName: "realName_example", djName: "djName_example") // NewDJ | 

// Update DJ information
DefaultAPI.djsRegisterPatch(newDJ: newDJ) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **newDJ** | [**NewDJ**](NewDJ.md) |  | 

### Return type

[**DJ**](DJ.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **djsRegisterPost**
```swift
    open class func djsRegisterPost(newDJ: NewDJ, completion: @escaping (_ data: DJ?, _ error: Error?) -> Void)
```

Register a new DJ

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI

let newDJ = NewDJ(cognitoUserName: "cognitoUserName_example", realName: "realName_example", djName: "djName_example") // NewDJ | 

// Register a new DJ
DefaultAPI.djsRegisterPost(newDJ: newDJ) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **newDJ** | [**NewDJ**](NewDJ.md) |  | 

### Return type

[**DJ**](DJ.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **flowsheetDelete**
```swift
    open class func flowsheetDelete(flowsheetDeleteRequest: FlowsheetDeleteRequest, completion: @escaping (_ data: FlowsheetEntryResponse?, _ error: Error?) -> Void)
```

Delete flowsheet entry

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI

let flowsheetDeleteRequest = _flowsheet_delete_request(entryId: 123) // FlowsheetDeleteRequest | 

// Delete flowsheet entry
DefaultAPI.flowsheetDelete(flowsheetDeleteRequest: flowsheetDeleteRequest) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **flowsheetDeleteRequest** | [**FlowsheetDeleteRequest**](FlowsheetDeleteRequest.md) |  | 

### Return type

[**FlowsheetEntryResponse**](FlowsheetEntryResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **flowsheetDjsOnAirGet**
```swift
    open class func flowsheetDjsOnAirGet(completion: @escaping (_ data: [OnAirDJ]?, _ error: Error?) -> Void)
```

Get list of DJs currently on air

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI


// Get list of DJs currently on air
DefaultAPI.flowsheetDjsOnAirGet() { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**[OnAirDJ]**](OnAirDJ.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **flowsheetEndPost**
```swift
    open class func flowsheetEndPost(flowsheetEndPostRequest: FlowsheetEndPostRequest, completion: @escaping (_ data: FlowsheetJoinPost200Response?, _ error: Error?) -> Void)
```

End or leave a show

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI

let flowsheetEndPostRequest = _flowsheet_end_post_request(djId: 123) // FlowsheetEndPostRequest | 

// End or leave a show
DefaultAPI.flowsheetEndPost(flowsheetEndPostRequest: flowsheetEndPostRequest) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **flowsheetEndPostRequest** | [**FlowsheetEndPostRequest**](FlowsheetEndPostRequest.md) |  | 

### Return type

[**FlowsheetJoinPost200Response**](FlowsheetJoinPost200Response.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **flowsheetGet**
```swift
    open class func flowsheetGet(limit: Int? = nil, showsLimit: Int? = nil, page: Int? = nil, startId: Int? = nil, endId: Int? = nil, completion: @escaping (_ data: [FlowsheetEntryResponse]?, _ error: Error?) -> Void)
```

Get flowsheet entries

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI

let limit = 987 // Int | Number of entries to return (optional)
let showsLimit = 987 // Int | Number of shows to return entries from (optional)
let page = 987 // Int | Page number for pagination (optional)
let startId = 987 // Int | First play_order id in range (must be provided with end_id) (optional)
let endId = 987 // Int | Last play_order id in range (must be provided with start_id) (optional)

// Get flowsheet entries
DefaultAPI.flowsheetGet(limit: limit, showsLimit: showsLimit, page: page, startId: startId, endId: endId) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **limit** | **Int** | Number of entries to return | [optional] 
 **showsLimit** | **Int** | Number of shows to return entries from | [optional] 
 **page** | **Int** | Page number for pagination | [optional] 
 **startId** | **Int** | First play_order id in range (must be provided with end_id) | [optional] 
 **endId** | **Int** | Last play_order id in range (must be provided with start_id) | [optional] 

### Return type

[**[FlowsheetEntryResponse]**](FlowsheetEntryResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **flowsheetJoinPost**
```swift
    open class func flowsheetJoinPost(flowsheetJoinPostRequest: FlowsheetJoinPostRequest, completion: @escaping (_ data: FlowsheetJoinPost200Response?, _ error: Error?) -> Void)
```

Start or join a show

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI

let flowsheetJoinPostRequest = _flowsheet_join_post_request(djId: 123, showName: "showName_example", specialtyId: 123) // FlowsheetJoinPostRequest | 

// Start or join a show
DefaultAPI.flowsheetJoinPost(flowsheetJoinPostRequest: flowsheetJoinPostRequest) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **flowsheetJoinPostRequest** | [**FlowsheetJoinPostRequest**](FlowsheetJoinPostRequest.md) |  | 

### Return type

[**FlowsheetJoinPost200Response**](FlowsheetJoinPost200Response.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **flowsheetLatestGet**
```swift
    open class func flowsheetLatestGet(completion: @escaping (_ data: FlowsheetEntryResponse?, _ error: Error?) -> Void)
```

Get the most recent flowsheet entry

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI


// Get the most recent flowsheet entry
DefaultAPI.flowsheetLatestGet() { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**FlowsheetEntryResponse**](FlowsheetEntryResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **flowsheetOnAirGet**
```swift
    open class func flowsheetOnAirGet(djId: Int? = nil, completion: @escaping (_ data: FlowsheetOnAirGet200Response?, _ error: Error?) -> Void)
```

Get on-air status for DJ

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI

let djId = 987 // Int |  (optional)

// Get on-air status for DJ
DefaultAPI.flowsheetOnAirGet(djId: djId) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **djId** | **Int** |  | [optional] 

### Return type

[**FlowsheetOnAirGet200Response**](FlowsheetOnAirGet200Response.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **flowsheetPatch**
```swift
    open class func flowsheetPatch(flowsheetUpdateRequest: FlowsheetUpdateRequest, completion: @escaping (_ data: FlowsheetEntryResponse?, _ error: Error?) -> Void)
```

Update flowsheet entry

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI

let flowsheetUpdateRequest = FlowsheetUpdateRequest(trackTitle: "trackTitle_example", artistName: "artistName_example", albumTitle: "albumTitle_example", recordLabel: "recordLabel_example", requestFlag: false) // FlowsheetUpdateRequest | 

// Update flowsheet entry
DefaultAPI.flowsheetPatch(flowsheetUpdateRequest: flowsheetUpdateRequest) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **flowsheetUpdateRequest** | [**FlowsheetUpdateRequest**](FlowsheetUpdateRequest.md) |  | 

### Return type

[**FlowsheetEntryResponse**](FlowsheetEntryResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **flowsheetPlayOrderPatch**
```swift
    open class func flowsheetPlayOrderPatch(flowsheetPlayOrderPatchRequest: FlowsheetPlayOrderPatchRequest, completion: @escaping (_ data: FlowsheetEntryResponse?, _ error: Error?) -> Void)
```

Update the play order of a flowsheet entry

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI

let flowsheetPlayOrderPatchRequest = _flowsheet_play_order_patch_request(entryId: 123, newPosition: 123) // FlowsheetPlayOrderPatchRequest | 

// Update the play order of a flowsheet entry
DefaultAPI.flowsheetPlayOrderPatch(flowsheetPlayOrderPatchRequest: flowsheetPlayOrderPatchRequest) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **flowsheetPlayOrderPatchRequest** | [**FlowsheetPlayOrderPatchRequest**](FlowsheetPlayOrderPatchRequest.md) |  | 

### Return type

[**FlowsheetEntryResponse**](FlowsheetEntryResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **flowsheetPlaylistGet**
```swift
    open class func flowsheetPlaylistGet(showId: Int, completion: @escaping (_ data: ShowPlaylist?, _ error: Error?) -> Void)
```

Get complete playlist for a show

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI

let showId = 987 // Int | 

// Get complete playlist for a show
DefaultAPI.flowsheetPlaylistGet(showId: showId) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **showId** | **Int** |  | 

### Return type

[**ShowPlaylist**](ShowPlaylist.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **flowsheetPost**
```swift
    open class func flowsheetPost(flowsheetPostRequest: FlowsheetPostRequest, completion: @escaping (_ data: FlowsheetEntryResponse?, _ error: Error?) -> Void)
```

Add entry to flowsheet

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI

let flowsheetPostRequest = _flowsheet_post_request(albumId: 123, trackTitle: "trackTitle_example", rotationId: 123, requestFlag: false, recordLabel: "recordLabel_example", artistName: "artistName_example", albumTitle: "albumTitle_example", message: "message_example") // FlowsheetPostRequest | 

// Add entry to flowsheet
DefaultAPI.flowsheetPost(flowsheetPostRequest: flowsheetPostRequest) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **flowsheetPostRequest** | [**FlowsheetPostRequest**](FlowsheetPostRequest.md) |  | 

### Return type

[**FlowsheetEntryResponse**](FlowsheetEntryResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **libraryArtistsPost**
```swift
    open class func libraryArtistsPost(addArtistRequest: AddArtistRequest, completion: @escaping (_ data: Artist?, _ error: Error?) -> Void)
```

Add new artist

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI

let addArtistRequest = AddArtistRequest(artistName: "artistName_example", codeLetters: "codeLetters_example", genreId: 123) // AddArtistRequest | 

// Add new artist
DefaultAPI.libraryArtistsPost(addArtistRequest: addArtistRequest) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **addArtistRequest** | [**AddArtistRequest**](AddArtistRequest.md) |  | 

### Return type

[**Artist**](Artist.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **libraryFormatsGet**
```swift
    open class func libraryFormatsGet(completion: @escaping (_ data: [FormatEntry]?, _ error: Error?) -> Void)
```

Get format list

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI


// Get format list
DefaultAPI.libraryFormatsGet() { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**[FormatEntry]**](FormatEntry.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **libraryFormatsPost**
```swift
    open class func libraryFormatsPost(libraryFormatsPostRequest: LibraryFormatsPostRequest, completion: @escaping (_ data: FormatEntry?, _ error: Error?) -> Void)
```

Add new format

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI

let libraryFormatsPostRequest = _library_formats_post_request(name: "name_example") // LibraryFormatsPostRequest | 

// Add new format
DefaultAPI.libraryFormatsPost(libraryFormatsPostRequest: libraryFormatsPostRequest) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **libraryFormatsPostRequest** | [**LibraryFormatsPostRequest**](LibraryFormatsPostRequest.md) |  | 

### Return type

[**FormatEntry**](FormatEntry.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **libraryGenresGet**
```swift
    open class func libraryGenresGet(completion: @escaping (_ data: [GenreEntry]?, _ error: Error?) -> Void)
```

Get genre list

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI


// Get genre list
DefaultAPI.libraryGenresGet() { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**[GenreEntry]**](GenreEntry.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **libraryGenresPost**
```swift
    open class func libraryGenresPost(libraryFormatsPostRequest: LibraryFormatsPostRequest, completion: @escaping (_ data: GenreEntry?, _ error: Error?) -> Void)
```

Add new genre

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI

let libraryFormatsPostRequest = _library_formats_post_request(name: "name_example") // LibraryFormatsPostRequest | 

// Add new genre
DefaultAPI.libraryGenresPost(libraryFormatsPostRequest: libraryFormatsPostRequest) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **libraryFormatsPostRequest** | [**LibraryFormatsPostRequest**](LibraryFormatsPostRequest.md) |  | 

### Return type

[**GenreEntry**](GenreEntry.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **libraryGet**
```swift
    open class func libraryGet(artistName: String? = nil, albumTitle: String? = nil, n: Int? = nil, page: Int? = nil, completion: @escaping (_ data: [AlbumSearchResult]?, _ error: Error?) -> Void)
```

Search for album

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI

let artistName = "artistName_example" // String |  (optional)
let albumTitle = "albumTitle_example" // String |  (optional)
let n = 987 // Int |  (optional)
let page = 987 // Int |  (optional)

// Search for album
DefaultAPI.libraryGet(artistName: artistName, albumTitle: albumTitle, n: n, page: page) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **artistName** | **String** |  | [optional] 
 **albumTitle** | **String** |  | [optional] 
 **n** | **Int** |  | [optional] 
 **page** | **Int** |  | [optional] 

### Return type

[**[AlbumSearchResult]**](AlbumSearchResult.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **libraryInfoGet**
```swift
    open class func libraryInfoGet(albumId: Int, completion: @escaping (_ data: AlbumInfoResponse?, _ error: Error?) -> Void)
```

Get album information

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI

let albumId = 987 // Int | 

// Get album information
DefaultAPI.libraryInfoGet(albumId: albumId) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **albumId** | **Int** |  | 

### Return type

[**AlbumInfoResponse**](AlbumInfoResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **libraryPost**
```swift
    open class func libraryPost(addAlbumRequest: AddAlbumRequest, completion: @escaping (_ data: Album?, _ error: Error?) -> Void)
```

Add new album

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI

let addAlbumRequest = AddAlbumRequest(albumTitle: "albumTitle_example", artistName: "artistName_example", artistId: 123, label: "label_example", genreId: 123, formatId: 123, discQuantity: 123, alternateArtistName: "alternateArtistName_example") // AddAlbumRequest | 

// Add new album
DefaultAPI.libraryPost(addAlbumRequest: addAlbumRequest) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **addAlbumRequest** | [**AddAlbumRequest**](AddAlbumRequest.md) |  | 

### Return type

[**Album**](Album.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **libraryRotationGet**
```swift
    open class func libraryRotationGet(completion: @escaping (_ data: [Rotation]?, _ error: Error?) -> Void)
```

Get rotation list

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI


// Get rotation list
DefaultAPI.libraryRotationGet() { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**[Rotation]**](Rotation.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **libraryRotationPatch**
```swift
    open class func libraryRotationPatch(killRotationRequest: KillRotationRequest, completion: @escaping (_ data: RotationEntry?, _ error: Error?) -> Void)
```

Set rotation removal date

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI

let killRotationRequest = KillRotationRequest(rotationId: 123, killDate: Date()) // KillRotationRequest | 

// Set rotation removal date
DefaultAPI.libraryRotationPatch(killRotationRequest: killRotationRequest) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **killRotationRequest** | [**KillRotationRequest**](KillRotationRequest.md) |  | 

### Return type

[**RotationEntry**](RotationEntry.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **libraryRotationPost**
```swift
    open class func libraryRotationPost(addRotationRequest: AddRotationRequest, completion: @escaping (_ data: RotationEntry?, _ error: Error?) -> Void)
```

Add new rotation

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI

let addRotationRequest = AddRotationRequest(albumId: 123, rotationBin: RotationBin()) // AddRotationRequest | 

// Add new rotation
DefaultAPI.libraryRotationPost(addRotationRequest: addRotationRequest) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **addRotationRequest** | [**AddRotationRequest**](AddRotationRequest.md) |  | 

### Return type

[**RotationEntry**](RotationEntry.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **libraryTracksGet**
```swift
    open class func libraryTracksGet(song: String, artist: String? = nil, album: String? = nil, label: String? = nil, n: Int? = nil, completion: @escaping (_ data: [TrackSearchResult]?, _ error: Error?) -> Void)
```

Search for tracks

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI

let song = "song_example" // String | 
let artist = "artist_example" // String |  (optional)
let album = "album_example" // String |  (optional)
let label = "label_example" // String |  (optional)
let n = 987 // Int |  (optional)

// Search for tracks
DefaultAPI.libraryTracksGet(song: song, artist: artist, album: album, label: label, n: n) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **song** | **String** |  | 
 **artist** | **String** |  | [optional] 
 **album** | **String** |  | [optional] 
 **label** | **String** |  | [optional] 
 **n** | **Int** |  | [optional] 

### Return type

[**[TrackSearchResult]**](TrackSearchResult.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **metadataAlbumGet**
```swift
    open class func metadataAlbumGet(albumId: Int, forceRefresh: Bool? = nil, completion: @escaping (_ data: MetadataFetchResponse?, _ error: Error?) -> Void)
```

Get album metadata

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI

let albumId = 987 // Int | 
let forceRefresh = true // Bool |  (optional)

// Get album metadata
DefaultAPI.metadataAlbumGet(albumId: albumId, forceRefresh: forceRefresh) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **albumId** | **Int** |  | 
 **forceRefresh** | **Bool** |  | [optional] 

### Return type

[**MetadataFetchResponse**](MetadataFetchResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **metadataArtistGet**
```swift
    open class func metadataArtistGet(artistId: Int, forceRefresh: Bool? = nil, completion: @escaping (_ data: MetadataFetchResponse?, _ error: Error?) -> Void)
```

Get artist metadata

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI

let artistId = 987 // Int | 
let forceRefresh = true // Bool |  (optional)

// Get artist metadata
DefaultAPI.metadataArtistGet(artistId: artistId, forceRefresh: forceRefresh) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **artistId** | **Int** |  | 
 **forceRefresh** | **Bool** |  | [optional] 

### Return type

[**MetadataFetchResponse**](MetadataFetchResponse.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **requestsGet**
```swift
    open class func requestsGet(completion: @escaping (_ data: [EnhancedRequest]?, _ error: Error?) -> Void)
```

Get song requests

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI


// Get song requests
DefaultAPI.requestsGet() { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**[EnhancedRequest]**](EnhancedRequest.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **requestsIdPatch**
```swift
    open class func requestsIdPatch(id: Int, requestsIdPatchRequest: RequestsIdPatchRequest, completion: @escaping (_ data: SongRequest?, _ error: Error?) -> Void)
```

Update request status

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI

let id = 987 // Int | 
let requestsIdPatchRequest = _requests__id__patch_request(status: RequestStatus()) // RequestsIdPatchRequest | 

// Update request status
DefaultAPI.requestsIdPatch(id: id, requestsIdPatchRequest: requestsIdPatchRequest) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **Int** |  | 
 **requestsIdPatchRequest** | [**RequestsIdPatchRequest**](RequestsIdPatchRequest.md) |  | 

### Return type

[**SongRequest**](SongRequest.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **requestsPost**
```swift
    open class func requestsPost(submitRequestPayload: SubmitRequestPayload, completion: @escaping (_ data: RequestSubmissionResponse?, _ error: Error?) -> Void)
```

Submit a song request

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI

let submitRequestPayload = SubmitRequestPayload(message: "message_example") // SubmitRequestPayload | 

// Submit a song request
DefaultAPI.requestsPost(submitRequestPayload: submitRequestPayload) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **submitRequestPayload** | [**SubmitRequestPayload**](SubmitRequestPayload.md) |  | 

### Return type

[**RequestSubmissionResponse**](RequestSubmissionResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **scheduleGet**
```swift
    open class func scheduleGet(completion: @escaping (_ data: [Schedule]?, _ error: Error?) -> Void)
```

Get schedule

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI


// Get schedule
DefaultAPI.scheduleGet() { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**[Schedule]**](Schedule.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **schedulePost**
```swift
    open class func schedulePost(addScheduleShiftRequest: AddScheduleShiftRequest, completion: @escaping (_ data: ScheduleShift?, _ error: Error?) -> Void)
```

Add to schedule

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI

let addScheduleShiftRequest = AddScheduleShiftRequest(djId: 123, day: DayOfWeek(), startTime: "startTime_example", endTime: "endTime_example", showName: "showName_example", specialtyId: 123) // AddScheduleShiftRequest | 

// Add to schedule
DefaultAPI.schedulePost(addScheduleShiftRequest: addScheduleShiftRequest) { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **addScheduleShiftRequest** | [**AddScheduleShiftRequest**](AddScheduleShiftRequest.md) |  | 

### Return type

[**ScheduleShift**](ScheduleShift.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **scheduleShiftsGet**
```swift
    open class func scheduleShiftsGet(completion: @escaping (_ data: [ScheduleShift]?, _ error: Error?) -> Void)
```

Get schedule shifts

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI


// Get schedule shifts
DefaultAPI.scheduleShiftsGet() { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**[ScheduleShift]**](ScheduleShift.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **scheduleSpecialtyGet**
```swift
    open class func scheduleSpecialtyGet(completion: @escaping (_ data: [SpecialtyShow]?, _ error: Error?) -> Void)
```

Get specialty shows

### Example
```swift
// The following code samples are still beta. For any issue, please report via http://github.com/OpenAPITools/openapi-generator/issues/new
import WXYCAPI


// Get specialty shows
DefaultAPI.scheduleSpecialtyGet() { (response, error) in
    guard error == nil else {
        print(error)
        return
    }

    if (response) {
        dump(response)
    }
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**[SpecialtyShow]**](SpecialtyShow.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

