E2Lib.RegisterExtension("submeshmaterials", true, "Adds some useful features (mainly getting submesh materials) not included in Prop2Mesh.")

local isOwner = E2Lib.isOwner
local newE2Table = E2Lib.newE2Table

local function getBodygroupMask(ent) -- this is basically straight from P2M - there's really only one way to do this
    --[[
        leaving this here until i make a separate text document for it:

        the way Source handles bodygroups is by listing every combination sequentially & numbering them from 0
        the mask is simply the number of a specific combination
        example: if a model has two bodygroups with two options each, Source would list them like this:
                    bg 1 | bg 2
            mask 0:   0  |  0
            mask 1:   1  |  0
            mask 2:   0  |  1
            mask 3:   1  |  1

        for the first bodygroup, the mask is just the index of whichever option is selected, the default being 0

        for the second, the index of the option selected is the number of times we need to "fill" the previous bodygroup,
        so the mask is (number of options in bg 1) * (index of selected option for bg 2)
        if bg 1 is something other than default (option 0), then we add that to the mask as well

        now, let's say we have a third bodygroup set to option 1, meaning we need to "fill" the second bodygroup once
        however, to increment the second bodygroup to its next option, we need to "fill" the FIRST one!
        so for the third bodygroup, the mask is (# of options in bg 1) * (# of options in bg 2) * (option selected for bg 3)
        (plus the mask for bg 2, plus the mask for bg 1)

        in general, to find the bodygroup mask for bodygroup B set to option N, we find
            (# of options in bg 1) * (# of options in bg 2) * ... * (# of options in bg B-1) * N
        and to find the overall mask, we do this for each bodygroup, then add them together
    ]]

    local bgMask = 0
    local offset = 1
    
    --[[ 
        here's the fun part: GetBodygroup, GetBodygroupCount, and GetNumBodyGroups are three different things.
            GetBodygroup returns which option is currently selected for a specified bodygroup.
            GetBodygroupCount returns the number of options for a specified bodygroup.
            GetNumBodyGroups returns the number of bodygroups an entity has.
            and we get to use all three! yay!!
    ]]
    for bg = 0, ent:GetNumBodyGroups()-1 do
        local bgOption = ent:GetBodygroup(bg)
        bgMask = bgMask + offset*bgOption
        offset = offset*ent:GetBodygroupCount(bg)
    end

    return bgMask
end




__e2setcost(50) --no idea what this should be; 50 is arbitrary

-- Returns an entity's submesh count (based on current bodygroups), or -1 if invalid.
e2function number entity:getSubmeshCount()
    if not IsValid(this) then return -1 end
    if not isOwner(self, entity) then return -1 end
    
    local submeshes = util.GetModelMeshes(this:GetModel(), 0, getBodygroupMask(this) or 0)

    return submeshes and #submeshes or 0
end

-- Returns a table of all submesh materials.
e2function table entity:getSubmeshMaterials()
    local matTable = newE2Table()

    if not IsValid(this) then return matTable end
    if not isOwner(self, entity) then return matTable end
    
    local submeshes = util.GetModelMeshes(this:GetModel(), 0, getBodygroupMask(this) or 0)
    local size = 0

    for m = 1, submeshes and #submeshes do
        size = size + 1
        local mat = submeshes[m].material
        matTable.n[m] = mat
        matTable.ntypes[m] = "s"
    end

    matTable.size = size

    return matTable
end



__e2setcost(10)

-- Returns an entity's bodygroup mask, or -1 if invalid.
e2function number entity:getBodygroupMask()
    if not IsValid(this) then return -1 end
    if not isOwner(self, entity) then return -1 end

    return getBodygroupMask(this) or 0
end