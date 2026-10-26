# SimpleSerializer

**SimpleSerializer** is a lightweight serialization library for Roblox that converts Luau values into a compact binary-style string and restores them back into their original types.

It supports standard Luau values, Roblox data types, and buffers, making it a useful alternative to JSON when you want to preserve Roblox-specific types without manually converting them.

> **Platform:** Roblox only. This library relies on Roblox-specific APIs and data types.

## Installation

### ModuleScript

Require the module normally:

```lua
local SimpleSerializer = require(path.to.SimpleSerializer)
```

### Exploit environments

You can also load it directly using `loadstring`:

```lua
local ss = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Its-Kawi/Utilities/refs/heads/main/SimpleSerializer/Main.lua"
))()
```

This method requires an environment that supports `loadstring` and `game:HttpGet`.

## Basic Usage

SimpleSerializer has two main functions: `serialize` and `deserialize`.

### `serialize(data)`

Converts a supported value into a serialized string.

```lua
local data = {
    Name = "Player",
    Level = 25,
    Active = true,
    Position = Vector3.new(10, 5, 20)
}

local serialized = ss.serialize(data)
print(serialized)
```

The result is a compact string containing encoded type information and data. It is not intended to be human-readable.

### `deserialize(data)`

Restores a value from a serialized string or Roblox buffer.

```lua
local restored = ss.deserialize(serialized)

print(restored.Name)     -- Player
print(restored.Level)    -- 25
print(restored.Active)   -- true
print(restored.Position) -- Vector3
```

You can also deserialize a buffer directly:

```lua
local buf = buffer.fromstring(serialized)
local restored = ss.deserialize(buf)
```

## Supported Types

SimpleSerializer supports the following types:

| Type | Support |
|---|---|
| `string` | Yes |
| `number` | Yes, including infinities and NaN |
| `boolean` | Yes |
| `nil` | Yes, as an encoded value |
| `table` | Yes, including lists and dictionaries |
| `buffer` | Yes |
| `Color3` | Yes |
| `CFrame` | Yes |
| `Vector2`, `Vector3` | Yes |
| `Vector2int16`, `Vector3int16` | Yes |
| `UDim`, `UDim2` | Yes |
| `ColorSequence` | Yes |
| `ColorSequenceKeypoint` | Yes |

Unsupported Roblox types and other values without an encoder are not serialized correctly and may result in errors.

## SimpleSerializer vs JSON

Unlike Roblox's `HttpService:JSONEncode()` and `JSONDecode()`, SimpleSerializer is designed to preserve Roblox data types directly.

| Feature | SimpleSerializer | JSON |
|---|---|---|
| Output | Compact, binary-style string | Readable text |
| Roblox data types | Supports several native types | Requires manual conversion |
| Buffers | Supported | Supported, but as a custom table with large data |
| Booleans and strings | Supported | Supported, but some strings can cause errors |
| Tables | Lists and dictionaries | Arrays and objects |
| `nil` | Encoded as a value | Encoded as `null` |
| Special numbers | Handles NaN and infinities | Supported, but as a custom table with large data |
| Human-readable | No | Yes |
| Web/API compatibility | Not intended for JSON APIs | Excellent |

**Use SimpleSerializer** when working with Roblox-specific data and compact serialization.

**Use JSON** when you need readable output, interoperability with web APIs, or a standard data format.

## Important Notes

- **Tables cannot be cyclic.** A table that references itself, directly or indirectly, is unsupported.
- **Dictionary keys should be serializable.** Keys are encoded just like values.
- **Empty tables** are supported.
- **Strings and buffers** are escaped where necessary to preserve the encoded data.
- **Numbers:** Extremely small floating-point values may be serialized as zero, and very large numbers may lose precision or fall back to infinity.
- **Malformed data:** `deserialize` raises an error if decoding fails. It does not return a separate success flag.
- **Nil values:** Although `nil` can be encoded directly, Lua tables cannot retain entries whose values are `nil`. A top-level serialized `nil` also deserializes to `nil`.

## Error Handling

Use `pcall` if the data may be invalid or unsupported:

```lua
local success, result = pcall(function()
    return ss.deserialize(serialized)
end)

if success then
    print("Deserialized successfully")
else
    warn("Failed to deserialize:", result)
end
```

The same approach can be used with `serialize`.

## License

Refer to the repository's license for usage and redistribution terms.
