# SimpleSerializer

SimpleSerializer is a serialization library for Roblox Luau. It converts supported Luau values into a compact binary-style string and reconstructs values from that serialized data.

It is designed for Roblox environments and can preserve a number of Roblox-specific types without requiring you to manually convert them into ordinary tables.

> **Platform:** Roblox Luau. This module uses Roblox APIs and data types.
>
> **Important:** Serialization is not encryption. Do not use it to hide secrets or to make untrusted data safe.

## Contents

- [Installation](#installation)
- [Basic usage](#basic-usage)
- [API reference](#api-reference)
- [Working with buffers](#working-with-buffers)
- [Supported types](#supported-types)
- [Special values and behavior](#special-values-and-behavior)
- [Error handling](#error-handling)
- [Limitations and safety](#limitations-and-safety)
- [SimpleSerializer vs. JSON](#simpleserializer-vs-json)
- [Complete example](#complete-example)

## Installation

Place `Main.lua` in your Roblox experience as a `ModuleScript`, then require it from a script that can access that module.

```lua
local SimpleSerializer = require(path.to.SimpleSerializer)
```

Replace `path.to.SimpleSerializer` with the actual location of your ModuleScript.

## Basic usage

The module exposes two main functions: `serialize` and `deserialize`.

### Serialize a value

`serialize(value)` converts a supported value into a serialized string.

```lua
local data = {
    Name = "Player",
    Level = 25,
    Active = true,
    Position = Vector3.new(10, 5, 20),
}

local serialized = SimpleSerializer.serialize(data)
print(typeof(serialized)) -- string
```

The result is compact encoded data, not text intended to be read or edited by hand.

### Deserialize a value

`deserialize(data)` reconstructs a value from a serialized string or a Roblox `buffer`.

```lua
local restored = SimpleSerializer.deserialize(serialized)

print(restored.Name)     -- Player
print(restored.Level)    -- 25
print(restored.Active)   -- true
print(restored.Position) -- Vector3 value
```

For supported values, deserializing serialized data reconstructs the corresponding value. Exact equality is not guaranteed for every numeric value; see [Limitations and safety](#limitations-and-safety).

## API reference

### `SimpleSerializer.serialize(value)`

| Item | Description |
| --- | --- |
| Argument | A value supported by the serializer |
| Returns | Serialized data as a string |
| Errors | May raise an error for unsupported values, cyclic tables, or other invalid input |

Example:

```lua
local success, result = pcall(SimpleSerializer.serialize, {
    Coins = 150,
    Spawn = CFrame.new(0, 10, 0),
})

if success then
    print("Serialized:", result)
else
    warn("Serialization failed:", result)
end
```

### `SimpleSerializer.deserialize(data)`

| Item | Description |
| --- | --- |
| Argument | Serialized data as a string or Roblox `buffer` |
| Returns | The reconstructed value |
| Errors | May raise an error if the input is invalid or malformed |

Example:

```lua
local success, result = pcall(SimpleSerializer.deserialize, serialized)

if success then
    print("Deserialized:", result)
else
    warn("Deserialization failed:", result)
end
```

Neither function returns a separate success boolean by default. Use `pcall` if you need to handle errors without stopping the current thread.

## Working with buffers

The serializer's output is a string. Roblox buffers can be converted to and from strings using the built-in `buffer` library.

```lua
local serialized = SimpleSerializer.serialize({
    Message = "Hello",
    Value = 123,
})

local buf = buffer.fromstring(serialized)
local restored = SimpleSerializer.deserialize(buf)

print(restored.Message) -- Hello
print(restored.Value)   -- 123
```

`deserialize` accepts either a serialized string or a buffer. Converting to a buffer is optional; use it when it fits the rest of your data pipeline.

## Supported types

The implementation includes encoders for the following values and Roblox types. Some values have special reconstruction behavior, described below.

| Type | Notes |
| --- | --- |
| `nil` | Can be serialized as a top-level value. A table cannot retain a key whose value is `nil`. |
| `boolean` | `true` and `false` |
| `number` | Includes special values such as positive infinity, negative infinity, and NaN; see numeric limitations below. |
| `string` | Encoded as serialized string data. |
| `table` | Supports lists and dictionaries, subject to the limitations below. |
| `buffer` | Binary buffer values are supported. |
| `Color3` | Uses the serializer's custom color representation. |
| `Instance` | Uses special instance handling; see [Instance values](#instance-values). |
| `Enum` | Enum types can be represented through the serializer's special-value handling. |
| `EnumItem` | Enum items can be represented through the serializer's special-value handling. |
| `Content` | Supported through special content handling; see [Content values](#content-values). |
| `function` | Function handling is special and environment-dependent; see [Functions and references](#functions-and-references). |
| Other Roblox datatypes | The implementation has custom handling for several Roblox datatypes. See the table below. |

### Roblox datatypes

| Type | Support |
| --- | --- |
| `Vector2` | Supported |
| `Vector3` | Supported |
| `Vector2int16` | Supported |
| `Vector3int16` | Supported |
| `CFrame` | Supported |
| `UDim` | Supported |
| `UDim2` | Supported |
| `ColorSequence` | Supported |
| `ColorSequenceKeypoint` | Supported |

The set of supported types is determined by the encoders in the current `Main.lua`. Unsupported types or values without a matching encoder may raise an error or fail to round-trip as expected.

## Special values and behavior

### Tables

SimpleSerializer supports list-like and dictionary-like tables. Keys are serialized too, so table keys must be supported values.

Tables must not contain cycles. A cycle occurs when a table references itself, directly or indirectly.

```lua
local data = {}
data.Self = data -- Creates a cycle; unsupported.

-- SimpleSerializer.serialize(data) will fail for cyclic tables.
```

Repeated references and cyclic references are not the same thing. Do not rely on reference identity being preserved unless the current implementation explicitly guarantees it.

### `nil` values

A top-level `nil` can be serialized and deserialized. However, standard Luau tables do not store entries whose values are `nil`.

```lua
local value = nil
local serialized = SimpleSerializer.serialize(value)
local restored = SimpleSerializer.deserialize(serialized)

print(restored == nil) -- true
```

For dictionaries, a field assigned `nil` is absent from the table; it cannot be recovered as a stored key/value entry.

### Numbers

The serializer handles ordinary numbers as well as NaN and infinities. Because floating-point values have finite precision, serialization may not preserve every number exactly.

Extremely small values may become zero, and very large values may lose precision or be represented as infinity. If your application depends on exact numeric values, test the specific ranges you intend to store.

### `Instance` values

`Instance` values use special handling. Do not assume that serializing an instance produces a complete, independent copy of the entire Roblox object hierarchy or that every instance can be reconstructed in every context. Behavior can depend on the instance and the environment in which deserialization occurs.

Test the exact instance types and use cases your experience requires before relying on this behavior for persistent data.

### `Enum` and `EnumItem` values

Enum types and enum items have special serialization handling. Test round-tripping any enum values that are important to your experience, especially when data may outlive a game update.

### `Content` values

`Content` values use special handling in the implementation. Confirm that the particular content value and target Roblox environment are supported by your current version before relying on round-trip behavior.

### Functions and references

The implementation includes special handling for functions and references to values available in its execution environment. This does **not** mean arbitrary functions can be converted into portable source code or safely restored in another environment.

Do not depend on a serialized function being available in another session, server, client, or runtime. Treat this behavior as environment-dependent and test it in the exact context where you intend to use it.

## Error handling

Invalid input and unsupported values may raise errors. Use `pcall` when data may be malformed or when you want the calling code to handle failures.

```lua
local serializedOk, serializedOrError = pcall(
    SimpleSerializer.serialize,
    { Score = 100 }
)

if not serializedOk then
    warn("Could not serialize:", serializedOrError)
    return
end

local deserializedOk, valueOrError = pcall(
    SimpleSerializer.deserialize,
    serializedOrError
)

if not deserializedOk then
    warn("Could not deserialize:", valueOrError)
    return
end

print(valueOrError.Score) -- 100
```

`pcall` catches errors; it does not validate whether a value is appropriate for your application's needs.

## Limitations and safety

- **Cyclic tables are unsupported.** Avoid tables that directly or indirectly reference themselves.
- **Keys must be serializable.** Table keys are encoded just like values.
- **Floating-point precision is limited.** Some very small or very large numbers may not round-trip exactly.
- **Malformed input can fail.** Handle deserialization errors when the source data is not fully trusted.
- **Serialization is not encryption.** Encoded data should not be treated as secret.
- **Serialization is not validation.** Successfully decoding data does not mean it is safe or appropriate to use.
- **Runtime-dependent values may not be portable.** In particular, do not assume instances, functions, or environment references can be restored in a different context.
- **Compatibility can change.** If you store serialized data permanently, test old saved data whenever you update the serializer.

When loading data from a DataStore or another persistence layer, consider using a version field in your own data structure so your game can recognize and migrate older formats.

## SimpleSerializer vs. JSON

Roblox also provides JSON support through `HttpService:JSONEncode()` and `HttpService:JSONDecode()`.

| Feature | SimpleSerializer | JSON |
| --- | --- | --- |
| Output | Compact encoded string | Human-readable text |
| Roblox-specific datatypes | Supports several types directly | Usually requires conversion to JSON-compatible values |
| Buffers | Supported by the serializer | Requires conversion to a JSON-compatible representation |
| Web API compatibility | Not intended as a standard interchange format | Widely supported |
| Readability | Not designed for manual editing | Readable and easy to inspect |
| Error handling | May raise errors for unsupported or malformed data | May raise errors for unsupported values or malformed JSON |

Choose SimpleSerializer when you need its supported Roblox-specific types and compact representation. Choose JSON when you need readable data or interoperability with web services.

The best choice depends on the values you need to store, the size of the data, and where the data will be used. Do not assume one format is always faster or smaller; benchmark representative data if performance matters.

## Complete example

This example serializes a table, restores it, and handles errors.

```lua
local SimpleSerializer = require(path.to.SimpleSerializer)

local playerData = {
    Level = 12,
    Coins = 450,
    IsPremium = false,
    LastPosition = Vector3.new(12, 4, -8),
    SpawnCFrame = CFrame.new(0, 10, 0),
    FavoriteColor = Color3.fromRGB(80, 170, 255),
}

local ok, serializedOrError = pcall(
    SimpleSerializer.serialize,
    playerData
)

if not ok then
    warn("Serialization failed:", serializedOrError)
    return
end

local decodeOk, restoredOrError = pcall(
    SimpleSerializer.deserialize,
    serializedOrError
)

if not decodeOk then
    warn("Deserialization failed:", restoredOrError)
    return
end

local restoredData = restoredOrError

print(restoredData.Level)
print(restoredData.Coins)
print(restoredData.LastPosition)
print(restoredData.SpawnCFrame)
print(restoredData.FavoriteColor)
```

This example demonstrates serialization in memory. It does not save the data to a DataStore; persistence must be implemented separately.

---

For the most accurate information about supported values and behavior, refer to the implementation in [`Main.lua`](https://github.com/Its-Kawi/Utilities/blob/main/SimpleSerializer/Main.lua).
