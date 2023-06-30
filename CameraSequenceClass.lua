--[[

    name: CameraSequenceClass
    description:  creates and stores a camera animation sequence using tween service

    functions
    _playSequence  ->  plays tween (sequence)
    .new()  ->  creates class

    methods
    :addSequence  ->  adds sequence to sequences table
    :playIndex  ->  finds and plays sequence by index
    :playAll  ->  loops through all sequences and plays tween

]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Packages = ReplicatedStorage.Packages

local Signal = require(Packages.signal)
local Sift = require(Packages.sift)

local camera = workspace.CurrentCamera

local sequence = {}
local sequencePrototype = {}
local sequencePrivate = {}

local function _playSequence(sequence)
    local startCFrame = sequence.startCFrame
    local endCFrame = sequence.endCFrame
    local delayTime = sequence.delayTime
    local tweenTime = sequence.tweenTime

    task.wait(delayTime)

    if sequence.startCFrame then
        camera.CFrame = startCFrame
    end

    local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
    local tweenGoal = {}
    tweenGoal.CFrame = endCFrame

    local tween = TweenService:Create(camera, tweenInfo, tweenGoal)

    tween:Play()
    tween.Completed:Wait()
end

--[[

    local sequenceClass = require(path-to-sequence)
    local mySequence = sequenceClass.new(5, CFrame.new(), CFrame.new())

    sequence.new(number, cframe, cframe)
    @tween time -> Number (time length of tween animation)
    @start cframe -> CFrame
    @end cframe -> CFrame

]]

function sequence.new(tweenTime, startCFrame, endCFrame)
    assert(tweenTime, "Attempt to index nil with argument 1.")
    assert(startCFrame, "Attempt to index nil with argument 2.")
    assert(endCFrame, "Attempt to index nil with argument 2.")

    local self = {}
    local private = {}

    self.sequenceCompleted = Signal.new()

    private.sequences = {
        [1] = {
            tweenTime = tweenTime,
            startCFrame = startCFrame,
            endCFrame = endCFrame,
        }
    }

    sequencePrivate[self] = private

    return setmetatable(self, sequencePrototype)
end

--[[

    mySequence:addSequence({
        startTime = CFrame.new(),
        endCFrame = CFrame.new(),
        tweenTime = 5, -> will resort to zero if nil
        delayTime = 5, -> will resort to zero if nil
    })

    mySequence:addSequence(table)
    @props -> Table {CFrame, CFrame, Number, Number}

]]

function sequencePrototype:addSequence(props)
    local startCFrame = props.startCFrame
    local endCFrame = props.endCFrame
    local tweenTime = props.tweenTime or 0
    local delayTime = props.delayTime or 0

    assert(endCFrame, "Attempt to index nil with position.")

    local private = sequencePrivate[self]

    local data = {
        tweenTime = tweenTime,
        startCFrame = startCFrame,
        endCFrame = endCFrame,
        delayTime = delayTime,
    }

    Sift.Array.push(private.sequences, data)
end

function sequencePrototype:playIndex(index)
    assert(index, "Attempt to index nil with argument 1.")

    local private = sequencePrivate[self]
    local sequence = private.sequences[index]
    _playSequence(sequence)

    self.sequenceCompleted:Fire(index)
end

function sequencePrototype:playAll(delayTime)
    delayTime = delayTime or 0

    local private = sequencePrivate[self]

    task.wait(delayTime)

    camera.CameraType = Enum.CameraType.Scriptable

    for index, sequence in private.sequences do
        _playSequence(sequence)

        self.sequenceCompleted:Fire(index)
    end
end

sequencePrototype.__index = sequencePrototype
sequencePrototype.__metatable = "This metatabl is locked."
sequencePrototype.__newindex = function(_, _, _)
    error("This metatable is locked.")
end

return sequence
