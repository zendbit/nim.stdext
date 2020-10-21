import json, options
import options_ext
export json

type
  FieldDesc* = tuple[name: string, nodeKind: JsonNodeKind]

proc `%`*(fieldDesc: FieldDesc): JsonNode =
 
  return %*{"name": fieldDesc.name, "nodeKind": fieldDesc.nodeKind}

proc fieldsDesc*(j: JsonNode): seq[FieldDesc] =

  result = @[]
  for k, v in j:
    result.add((k, v.kind))

proc names*(fieldsDesc: seq[FieldDesc]): seq[string] =
  for f in fieldsDesc:
    result.add(f.name)

proc fieldsDesc*[T](obj: T): seq[FieldDesc] =
  for k, v in obj.fieldPairs:
    let vtype = cast[type v](v)
    if vtype is Option:
      if vtype is Option[SomeInteger]:
        result.add((k, JInt))
      elif vtype is Option[SomeFloat]:
        result.add((k, JFloat))
      elif vtype is Option[string]:
        result.add((k, JString))
      elif vtype is Option[bool]:
        result.add((k, JBool))
      elif vtype is Option[array] or vType is Option[seq]:
        result.add((k, JArray))
      elif vtype is Option[RootObj]:
        result.add((k, JObject))
      else:
        result.add((k, JNull))
    else:
      if v is SomeInteger:
        result.add((k, JInt))
      elif v is SomeFloat:
        result.add((k, JFloat))
      elif v is string:
        result.add((k, JString))
      elif v is bool:
        result.add((k, JBool))
      elif v is array or v is seq:
        result.add((k, JArray))
      elif v is RootObj:
        result.add((k, JObject))
      else:
        result.add((k, JNull))

proc filter*(
  j: JsonNode,
  p: proc (x: JsonNode): bool): JsonNode =

  case j.kind
  of JObject:
    result = newJObject()
    for k, v in j:
      if p(v):
        result[k] = v
  of JArray:
    result = newJArray()
    for v in j:
      if p(v):
        result.add(v)
  else:
    raise newException(ValueError, "invalid parameter should be JObject or JArray")

proc discardNull*(j: JsonNode): JsonNode =
  return j.filter(proc (x: JsonNode): bool = x.kind != JNull)

proc map*(
  j: JsonNode,
  p: proc (x: JsonNode): JsonNode): JsonNode =

  case j.kind
  of JObject:
    result = newJObject()
    for k, v in j:
      result[k] = p(v)
  of JArray:
    result = newJArray()
    for v in j:
      result.add(p(v))
  else:
    raise newException(ValueError, "invalid parameter should be JObject or JArray")

proc delete*(
  node: JsonNode,
  keys: openArray[string]): JsonNode =
  result = node
  for k in keys:
    result.delete(k)

