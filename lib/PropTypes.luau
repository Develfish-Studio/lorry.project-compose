--!strict

local WithBundle = {}

export type WithBundle = {
  bundle: BundleData
}

export type BundleData = {
  name: string,
}

return WithBundle
