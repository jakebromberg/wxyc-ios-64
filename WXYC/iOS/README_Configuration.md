# Configuration Service

The `ConfigurationService` provides a centralized way to manage environment-specific configuration in the WXYC iOS app.

## Overview

The service uses a custom `TESTING` build flag to automatically switch between environments:
- **TESTING builds**: Use `http://localhost:8080` for local development and testing
- **All other builds** (Debug/Release): Use `https://api.wxyc.org` for production

## Setup

### Adding the TESTING Flag

1. **Open your project in Xcode**
2. **Select your project** in the navigator (blue project icon)
3. **Select your target** (WXYC)
4. **Go to "Build Settings" tab**
5. **Search for "Swift Compiler - Custom Flags"**
6. **Find "Other Swift Flags"**
7. **Add `-DTESTING` for your test scheme**

### Alternative: Create a Testing Build Configuration

1. **Duplicate your Debug configuration**
2. **Name it "Testing"**
3. **Add `TESTING=1` to "Preprocessor Macros"**

## Usage

### Basic Usage

```swift
import Foundation

// Get the base API URL
let baseURL = ConfigurationService.shared.apiBaseURL

// Get specific endpoint URLs
let requestURL = ConfigurationService.shared.requestEndpointURL
let dpopTokenURL = ConfigurationService.shared.dpopTokenEndpointURL

// Get current environment name
let environment = ConfigurationService.shared.environmentName
```

### In Services

```swift
final actor MyService {
    func makeRequest() async throws {
        let url = ConfigurationService.shared.requestEndpointURL
        var request = URLRequest(url: url)
        // ... rest of request logic
    }
}
```

### Environment Detection

The service automatically detects the environment using the custom TESTING flag:

```swift
#if TESTING
    // Testing environment - use localhost
    return URL(string: "http://localhost:8080")!
#else
    // Production environment - use production API
    return URL(string: Secrets.apiBaseUrl)!
#endif
```

## Benefits

1. **Explicit Environment Control**: Clear separation between testing and production
2. **Centralized Configuration**: All environment-specific settings are in one place
3. **Type Safety**: URLs are properly typed and validated
4. **Easy Testing**: Tests automatically use localhost URLs when TESTING flag is set
5. **Consistent**: All services use the same configuration source
6. **Flexible**: Can run in simulator for development without affecting API endpoints

## Adding New Endpoints

To add a new endpoint, simply add a computed property to `ConfigurationService`:

```swift
var newEndpointURL: URL {
    return apiBaseURL.appendingPathComponent("new-endpoint")
}
```

## Testing

The service includes comprehensive tests that verify:
- Singleton pattern works correctly
- Environment detection works with TESTING flag
- All endpoint URLs are constructed correctly
- Environment names are accurate

Run tests with: `⌘+U` in Xcode

## Migration

If you have hardcoded URLs in your code, replace them with calls to `ConfigurationService.shared`:

**Before:**
```swift
let url = URL(string: "http://localhost:8080/endpoint")!
```

**After:**
```swift
let url = ConfigurationService.shared.endpointURL
```

## Security

- Production URLs are stored in the `Secrets` module using obfuscation
- Localhost URLs are only available when TESTING flag is set
- The service is an actor, ensuring thread-safe access
- Clear separation between testing and production environments
