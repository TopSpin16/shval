#!/usr/bin/ruby -w
#
# Filter and modify a computation graph produced by the "trace" tool.
#
# This file is part of SHVAL. For details, see https://github.com/crafthpc/shval
#
# Please also see the LICENSE file for our notice and the LGPL.
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License (as published by the Free
# Software Foundation) version 2.1 dated February 1999.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the IMPLIED WARRANTY OF MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the terms and conditions of the GNU General
# Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program; if not, write to the Free Software Foundation, Inc.,
# 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#

# a single trace computational graph node
class TraceNode
  attr_reader :id, :label
  attr_accessor :in, :out

  def initialize (id, label)
    @id, @label = id, label
    @in, @out = [], []
  end

  # convert to DOT format (including outgoing edges)
  def to_s
    "#{@id.to_s} [label=\"#{@label.to_s}\"];\n" +
    @out.map { |id| "#{@id} -> #{id};" }.join("\n")
  end

end

# data structures
graph = Hash.new      # map: id => node
edges = []            # list of [src,dst] pairs

# load graph from DOT file
ARGF.each_line do |line|
  if line =~ /^(\d+) \[label="([^"]*)"\];$/
    graph[$1.to_i] = TraceNode.new($1.to_i, $2)
  elsif line =~ /^(\d+) -> (\d+);$/
    edges << [$1.to_i, $2.to_i]       # save edge info for later
  end
end

# add all edge information to graph
edges.each do |src,dst|
  graph[src].out << dst
  graph[dst].in << src
end

# for example, keep only nodes with at least incoming or outgoing edge
graph.select! { |id,node| node.in.size > 0 or node.out.size > 0 }

# re-output graph in DOT format
puts "digraph trace {"
graph.each do |id,node|
  puts node
end
puts "}"

