--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Wrapper = require('@lorry.project/lib/Wrapper')
local Project = require('@lorry.project/lib/Project')
local Profile = require('./Profile')
local Image = require('./Image')

local Make = {
  Image = Image,
  Profile = Profile,
}

export type Make = typeof(Make)

export type MakeProps = {
  project: Project.Project,
  images: {Image.Image},
  profiles: {Profile.Profile},
}

export type MakeImpl = Make & MakeProps

export type Unwrapped = {
  project: Project.UnwrappedProject,
  build: {
    images: {Image.Unwrapped}?,
  },
  run: {
    profiles: {Profile.Unwrapped}?,
  }
}
export type AnyChild = Profile.Profile | Image.Image

function Make:new(o: MakeProps): Make
  return Meta:type(o, self, 'Make')
end

function Make:from(project: Project.Project): Make
  assert(project ~= nil)
  return Make:new({
    project = project,
    images = Meta:array {},
    profiles = Meta:array {},
  })
end

function Make:setup(children: {AnyChild}): Make
  local this = self::MakeImpl
  children = children or Meta:array {}
  for _, child in children do
    this:with_child(child)
  end
  return this
end

function Make:with_child(child: {AnyChild}): Make
  local this = self::MakeImpl
  local tag = Meta:typeof(child)
  if tag == 'Make.Profile' then
    this.profiles[#this.profiles + 1] = child::Profile.Profile
  elseif tag == 'Make.Image' then
    this.images[#this.images + 1] = child::Image.Image
  end
  return this
end

function Make:with_image(name: string, bundle: string, namespace: string): Make
  local this = self::MakeImpl
  this:with_child(Image:from(name, bundle, namespace))
  return self
end

function Make:with_profile(name: string): Make
  local this = self::MakeImpl
  this:with_child(Profile:from(name))
  return self
end

function Make:unwrap(): Unwrapped
  local this = self::MakeImpl
  return {
    project = this.project:unwrap_project(),
    run = {
      profiles = Wrapper:unwrap_array_or_nil(this.profiles),
    },
    build = {
      images = Wrapper:unwrap_array_or_nil(this.images),
    }
  }
end

return Make
