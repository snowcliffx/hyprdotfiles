--!native
--!optimize 2

type BinaryHeap<T> = typeof(setmetatable({} :: BinaryHeapFields<T>, {} :: BinaryHeapImpl<T>))
type Node<T> = typeof(setmetatable({} :: NodeFields<T>, {} :: NodeImpl<T>))

type NodeFields<T> = {
	parent: Node<T>?,
	--left: Node<T>?,
	--right: Node<T>?,
	value: T,
}

type NodeImpl<T> = {
	__index: NodeImpl<T>,

	Swap: (self: Node<T>, other_node: Node<T>) -> (),
}

type BinaryHeapFields<T> = {
	nodes: { Node<T> },
}

type BinaryHeapImpl<T> = {
	__index: BinaryHeapImpl<T>,

	Insert: (self: BinaryHeap<T>, val: T) -> (),
	Peek: (self: BinaryHeap<T>) -> Node<T>,
	Remove: (self: BinaryHeap<T>, pos: number) -> Node<T>,
	Pop: (self: BinaryHeap<T>) -> Node<T>?,
	Size: (self: BinaryHeap<T>) -> number
}

local Node = {} :: NodeImpl<any>
Node.__index = Node

function Node:Swap<T>(other_node: Node<T>)
	self.value, other_node.value = other_node.value, self.value
end

local BinaryHeap = {} :: BinaryHeapImpl<any>
BinaryHeap.__index = BinaryHeap

local function NewNode<T>(val: T): Node<T>
	local node_fields: NodeFields<T> = { value = val }
	return setmetatable(node_fields, Node)
end

function BinaryHeap:Insert<T>(val: T)
	local cursor = self:Size() + 1
	local current_node = NewNode(val)
	self.nodes[cursor] = current_node

	if self:Size() ~= 0 then
		local parent_node_index = math.floor(cursor / 2)
		current_node.parent = self.nodes[parent_node_index]

		while current_node.parent and current_node.value > current_node.parent.value do
			current_node:Swap(current_node.parent)
			current_node = current_node.parent
		end
	end
end

function BinaryHeap:Peek()
	return self.nodes[1]
end

function BinaryHeap:Pop()
	if self.nodes[1] ~= nil then
		return self:Remove(1)
	end

	return nil
end

--[[
WIP
WIP
WIP
]]

function BinaryHeap:Remove(pos: number)
	local node = self.nodes[pos]

	return node
end

function BinaryHeap:Size()
	return #self.nodes
end