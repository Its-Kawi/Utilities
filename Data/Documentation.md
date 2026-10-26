# DataLibrary

**DataLibrary** is a lightweight messaging library for Roblox exploit environments. It lets scripts communicate through named channels, send data to other users, receive messages, and handle raw string messages without having to build the entire communication system yourself.

The source is obfuscated, so this documentation covers the public API rather than its internal implementation.

## Requirements

- A Roblox exploit environment that supports `loadstring`, `game:HttpGet`, and the required HTTP functionality.
- WebSocket support is recommended for more responsive message delivery. HTTP polling is used as a fallback.

**Important:** This library is designed for exploit environments and is not intended to run as a normal Roblox Studio ModuleScript.

## Loading the Library

```lua
local DataLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Its-Kawi/Utilities/refs/heads/main/Data/Main.lua"))()
```

The library is cached globally, so loading it again in the same environment returns the existing instance.

## Creating a Channel

Channels are used to organize communication. Scripts using the same channel name can communicate through that channel.

```lua
local Channel = DataLib.new("MyChannel")
```

Each channel provides methods for sending messages and events for receiving them.

## Sending Messages

### Send structured data

Use `Send()` to send data that can be serialized by the library.

```lua
Channel:Send({
    Action = "Update",
    Value = 100
})
```

### Send raw strings

Use `SendRaw()` when you want to send a plain string instead.

```lua
Channel:SendRaw("Hello, world!")
```

### Send to a specific player

Both methods accept an optional target player or encoded target string.

```lua
Channel:Send("Hello!", targetPlayer)
```

When no target is specified, the message is sent without a specific recipient restriction.

### Asynchronous methods

| Method | Description |
|---|---|
| `Send(data, target?)` | Sends structured data. |
| `SendAsync(data, target?)` | Sends structured data and waits for success. |
| `SendAsyncUnsafe(data, target?)` | Attempts to send once without retrying. |
| `SendRaw(str, target?)` | Sends a raw string. |
| `SendRawAsync(str, target?)` | Sends raw data and waits for success. |
| `SendRawAsyncUnsafe(str, target?)` | Attempts a raw send once without retrying. |

The `Unsafe` methods do not retry failed sends. The regular asynchronous methods retry until a send succeeds, so they can wait indefinitely if the backend remains unavailable.

## Receiving Messages

Use `OnMessage` for structured messages and `OnMessageRaw` for raw strings.

```lua
Channel.OnMessage:Connect(function(data, sender, message)
    print("Received:", data)
    print("Sender:", sender)
end)

Channel.OnMessageRaw:Connect(function(data, sender, message)
    print("Raw message:", data)
end)
```

The callbacks receive:

- `data` — The decoded message content.
- `sender` — The corresponding Roblox `Player`, when available.
- `message` — The complete message information table.

A sender may be `nil` if the corresponding player cannot be resolved.

### Complete message information

The `message` table can contain the following fields:

| Field | Description |
|---|---|
| `Hash` | Sender's hash. |
| `Sender` | Resolved `Player`, if available. |
| `IsServerMessage` | Whether the message originated from the server (usually always false). |
| `Message` | Decoded message content. |
| `Text` | Alias for `Message`. |
| `Timestamp` | Message timestamp supplied by the backend. |
| `MessageId` | Message identifier. |
| `IsRaw` | Whether the message is a raw string. |
| `ViaHTTP` | Whether the message arrived through HTTP polling. |
| `ChannelName` | Name of the channel. |

For an event that handles both structured and raw messages, use `MessageReceived`.

```lua
Channel.MessageReceived:Connect(function(message)
    print(message.ChannelName, message.Text)
end)
```

## Existing Channels

Use `fromExisting()` or `get()` to retrieve a channel by name. If the channel is not already cached locally, the library creates it.

```lua
local Channel = DataLib.get("MyChannel")
-- Equivalent:
local Channel = DataLib.fromExisting("MyChannel")
```

These methods are useful when multiple parts of a script need to access the same channel.

## Library Properties

| Property | Description |
|---|---|
| `DataLib.PollingSpeed` | HTTP polling interval in seconds. Must be greater than `0`. Default: `0.75`. |
| `DataLib.Ping` | Time taken by the latest HTTP polling operation, in seconds. Starts at `-1`. |
| `DataLib.DisableWebSockets` | Disables WebSocket connections when set to `true`. |

Example:

```lua
DataLib.PollingSpeed = 1
DataLib.DisableWebSockets = true
```

A lower polling interval can improve HTTP message responsiveness but increases request frequency. WebSockets are generally preferable when available.

## Channel Properties and Methods

| Member | Description |
|---|---|
| `Channel.ChannelName` | Channel name. |
| `Channel.Enabled` | Enables or suppresses delivery to the channel's message events. |
| `Channel.Disconnected` | Whether the channel has been disconnected. |
| `Channel.Ping` | Time since the last message received by this channel, in seconds. |
| `Channel:Disconnect()` | Disconnects the channel's local message listener. |

`Disconnect()` does not delete the remote channel. It stops the channel from processing further incoming events locally.

## Player Validation

`Validate()` checks whether a Roblox user ID matches an encoded player identifier.

```lua
local valid = DataLib:Validate(userId, hash)
```

Returns `true` if the identifier matches, otherwise `false`.

## Notes

- Channel names should be consistent between communicating scripts.
- Structured messages must contain data supported by the library's serializer.
- Raw messages must be strings. Raw messsages differ from normal ones, because they are not encoded by the library
- `SendAsync()` and `SendRawAsync()` can wait indefinitely if sending never succeeds.
- WebSocket availability depends on the executor environment.
- The library uses a remote backend, so delivery depends on backend availability and connectivity.
- Obfuscation does not replace server-side access controls. Do not treat channel names or encoded identifiers as authentication or assume messages are private or trusted.
