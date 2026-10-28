# DataLibrary

**DataLibrary** is a lightweight messaging library for Roblox exploit environments. It lets scripts communicate through named channels, send data to other users, receive messages, and handle raw string messages without building the communication system yourself.

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

Channels organize communication. Scripts using the same channel name can communicate through that channel.

```lua
local Channel = DataLib.new("MyChannel")
```

Each channel provides methods for sending messages and events for receiving them.
Channel properties:
| Property | Description |
|---|---|
| `.Enabled` | Allows/Disallows channel's listening events to be fired |
| `.Ping` (read only) | Channel's ping value |
| `.ChannelName` (read only) | Channel's name ("MyChannel" as in the example) |
| `.Disconnected` (read only) | True when `:Disconnect()` was called on the channel |
| `.HTTPMode` (read only) | If channel uses HTTP mode |
| `.WebSocketMode` (read only) | If channel uses WebSocket mode |

Channel events:
| Event | Description |
|---|---|
| `.OnMessage(data : any, sender : Player?, message : { ... })` | Being fired when a channel recieves a message |
| `.OnMessageRaw(data : string, sender : Player?, message : { ... })` | Being fired when a channel recieves a raw message |
| `.MessageReceived(message : { ... })` | Being fired when a channel recieves raw/normal message |
| `.Disconnecting()` | Being fired when `:Disconnect()` been called on a channel |
Events act like normal Roblox events which use `:Connect():Disconnect()`, `:Once()` and etc.

Channel methods:
| Method | Description |
|---|---|
| `:Disconnect()` | `:Disconnect()` does not delete the remote channel. It disconnects the local listener, stops further message event delivery, and resets the channel's ping value to `-1`. |

## Sending Messages
### Send structured data

Use `Send()` to send data supported by the library's serializer.

```lua
Channel:Send({
    Action = "Update",
    Value = 100
})
```

### Send raw strings

Use `SendRaw()` to send a plain string without passing it through the structured serializer.

```lua
Channel:SendRaw("Hello, world!")
```

Raw messages must be strings. They still pass through the library's message encoding process.

### Send to a specific player

Both methods accept an optional target player or encoded target string.

```lua
Channel:Send("Hello!", targetPlayer)
```

When no target is specified, the message is sent without a specific recipient restriction.

### Send methods

| Method | Description |
|---|---|
| `:Send(data, target?)` | Sends structured data through the library's asynchronous wrapper. |
| `:SendAsync(data, target?)` | Retries until the structured message sends successfully. |
| `:SendAsyncUnsafe(data, target?)` | Attempts one structured send without retrying. |
| `:SendRaw(str, target?)` | Sends a raw string through the library's asynchronous wrapper. |
| `:SendRawAsync(str, target?)` | Retries until the raw message sends successfully. |
| `:SendRawAsyncUnsafe(str, target?)` | Attempts one raw send without retrying. |

The retrying asynchronous methods can wait indefinitely if the backend remains unavailable.

`SendAsync()` and `SendRawAsync()` return `true` and the total elapsed time in seconds after successfully sending. Their timing includes send attempts and retry delays.

The single-attempt methods return a success status and the elapsed time for the attempt, except when sending is disabled, in which case `TrySend()` returns `false`.

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

| Field | Description |
|---|---|
| `Hash` | Encoded sender identifier. |
| `Sender` | Resolved `Player`, if available. |
| `IsServerMessage` | Whether the message originated from the server. |
| `Message` | Decoded message content. |
| `Text` | Alias for `Message`. |
| `Timestamp` | Timestamp supplied by the backend. |
| `Took` | Computed message timing value, in seconds. |
| `MessageId` | Message identifier. |
| `IsRaw` | Whether the message is a raw string. |
| `ViaHTTP` | Whether the message arrived through HTTP polling. |
| `ChannelName` | Name of the channel. |

### Receiving the complete message

Use `MessageReceived` when you need the complete message table instead of separate callback arguments.

```lua
Channel.MessageReceived:Connect(function(message)
    print("Channel:", message.ChannelName)
    print("Content:", message.Text)
    print("Sender:", message.Sender)
    print("Timing:", message.Took)
end)
```

`MessageReceived` fires for both structured and raw messages, provided the channel is enabled.

## Existing Channels

Use `get()` or `fromExisting()` to retrieve a channel by name. If the channel is not already cached locally, the library creates it.

```lua
local Channel = DataLib.get("MyChannel")

-- Equivalent:
local Channel = DataLib.fromExisting("MyChannel")
```

These methods are useful when multiple parts of a script need to access the same channel.

## Library Properties

| Property | Description |
|---|---|
| `DataLib.PollingSpeed` | HTTP polling interval in seconds. Must be greater than `0`. Default: `0.35`. |
| `DataLib.Ping` | Latest library timing value, in seconds. Starts at `-1`. |
| `DataLib.DisableWebSockets` | Disables WebSocket connections when set to `true`. |

Example:

```lua
DataLib.PollingSpeed = 1
DataLib.DisableWebSockets = true
```

A lower polling interval can improve HTTP message responsiveness but increases request frequency. WebSockets are generally preferable when available.

`DataLib.Ping` may reflect the duration of an HTTP polling operation or the timing value calculated when a message is received.

## Player Validation

`DataLib:Validate()` checks whether a Roblox user ID matches an encoded player identifier.

```lua
local valid = DataLib:Validate(userId, hash)
```

Returns `true` if the identifier matches, otherwise `false`.

## Notes

- Channel names should be consistent between communicating scripts.
- Structured messages must contain data supported by the library's serializer.
- Raw messages must be strings and bypass the structured serializer.
- The retrying send methods can wait indefinitely if sending never succeeds.
- WebSocket availability depends on the executor environment.
- Message delivery depends on the remote backend and network connectivity.
- The library caches generated message payloads internally. Avoid assuming that changing the target or message type while reusing the same data value will always generate a fresh payload in this version.
- Obfuscation does not replace server-side access controls. Do not treat channel names or encoded identifiers as authentication, or assume messages are private or trusted.
