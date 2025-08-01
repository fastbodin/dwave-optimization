# Copyright 2024 D-Wave
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

from libcpp.memory cimport shared_ptr
from libcpp.optional cimport optional
from libcpp.span cimport span
from libcpp.string cimport string
from libcpp.unordered_map cimport unordered_map
from libcpp.vector cimport vector

from libcpp cimport bool

from dwave.optimization.libcpp cimport  variant
from dwave.optimization.libcpp.array cimport Array, Slice
from dwave.optimization.libcpp.graph cimport ArrayNode, Graph, Node
from dwave.optimization.libcpp.state cimport State

# Cython gets confused when templating pointers
ctypedef const Array* ArrayPtr
ctypedef ArrayNode* ArrayNodePtr


cdef extern from "dwave-optimization/nodes/collections.hpp" namespace "dwave::optimization" nogil:
    cdef cppclass DisjointBitSetsNode(Node):
        void initialize_state(State&, vector[vector[double]]) except+
        Py_ssize_t primary_set_size() const
        Py_ssize_t num_disjoint_sets() const

    cdef cppclass DisjointBitSetNode(ArrayNode):
        Py_ssize_t set_index()

    cdef cppclass DisjointListsNode(Node):
        void initialize_state(State&, vector[vector[double]]) except+
        Py_ssize_t num_disjoint_lists() const
        Py_ssize_t primary_set_size() const

    cdef cppclass DisjointListNode(ArrayNode):
        Py_ssize_t list_index()

    cdef cppclass ListNode(ArrayNode):
        ListNode(Py_ssize_t) except+
        void initialize_state(State&, vector[double]) except+

    cdef cppclass SetNode(ArrayNode):
        SetNode(Py_ssize_t, Py_ssize_t, Py_ssize_t) except+
        void initialize_state(State&, vector[double]) except+


cdef extern from "dwave-optimization/nodes/constants.hpp" namespace "dwave::optimization" nogil:
    cdef cppclass ConstantNode(ArrayNode):
        const double* buff() const


cdef extern from "dwave-optimization/nodes/creation.hpp" namespace "dwave::optimization" nogil:
    cdef cppclass ARangeNode(ArrayNode):
        ctypedef variant[ArrayPtr, Py_ssize_t] array_or_int

        array_or_int start() const
        array_or_int stop() const
        array_or_int step() const


cdef extern from "dwave-optimization/nodes/flow.hpp" namespace "dwave::optimization" nogil:
    cdef cppclass ExtractNode(ArrayNode):
        pass

    cdef cppclass WhereNode(ArrayNode):
        pass


# This would usually be defined in here, but we need it for Graph.inputs() so to
# avoid the circular dependency we define it in graph.pxd.
from dwave.optimization.libcpp.graph cimport InputNode


cdef extern from "dwave-optimization/nodes/indexing.hpp" namespace "dwave::optimization" nogil:
    cdef cppclass AdvancedIndexingNode(ArrayNode):
        ctypedef variant[ArrayNodePtr, Slice] array_or_slice

        span[const array_or_slice] indices()

    cdef cppclass BasicIndexingNode(ArrayNode):
        ctypedef variant[Slice, Py_ssize_t] slice_or_int

        vector[slice_or_int] infer_indices() except +

    cdef cppclass PermutationNode(ArrayNode):
        pass


cdef extern from "dwave-optimization/nodes/interpolation.hpp" namespace "dwave::optimization" nogil:
    cdef cppclass BSplineNode(ArrayNode):
        int k()
        vector[double] t()
        vector[double] c()


cdef extern from "dwave-optimization/nodes/lp.hpp" namespace "dwave::optimization" nogil:
    cdef cppclass LinearProgramFeasibleNode(ArrayNode):
        pass

    cdef cppclass LinearProgramNode(Node):
        unordered_map[string, ssize_t] get_arguments()
        void initialize_state(State&, ...) except +  # Cython gets confused between span<double> and span<const double>
        span[const double] solution(const State&) const
        span[const Py_ssize_t] variables_shape() const

    cdef cppclass LinearProgramNodeBase(Node):
        pass

    cdef cppclass LinearProgramObjectiveValueNode(ArrayNode):
        pass

    cdef cppclass LinearProgramSolutionNode(ArrayNode):
        pass


cdef extern from "dwave-optimization/nodes/lambda.hpp" namespace "dwave::optimization" nogil:
    cdef cppclass AccumulateZipNode(ArrayNode):
        ctypedef variant[ArrayNodePtr, double] array_or_double
        shared_ptr[Graph] expression_ptr()
        const array_or_double initial


cdef extern from "dwave-optimization/nodes/manipulation.hpp" namespace "dwave::optimization" nogil:
    cdef cppclass ConcatenateNode(ArrayNode):
        Py_ssize_t axis()

    cdef cppclass CopyNode(ArrayNode):
        pass

    cdef cppclass PutNode(ArrayNode):
        pass

    cdef cppclass ReshapeNode(ArrayNode):
        pass

    cdef cppclass ResizeNode(ArrayNode):
        double fill_value() const

    cdef cppclass SizeNode(ArrayNode):
        pass


cdef extern from "dwave-optimization/nodes/mathematical.hpp" namespace "dwave::optimization" nogil:
    cdef cppclass AbsoluteNode(ArrayNode):
        pass

    cdef cppclass AddNode(ArrayNode):
        pass

    cdef cppclass AllNode(ArrayNode):
        pass

    cdef cppclass AndNode(ArrayNode):
        pass

    cdef cppclass AnyNode(ArrayNode):
        pass

    cdef cppclass DivideNode(ArrayNode):
        pass

    cdef cppclass EqualNode(ArrayNode):
        pass

    cdef cppclass ExpitNode(ArrayNode):
        pass

    cdef cppclass ExpNode(ArrayNode):
        pass

    cdef cppclass LessEqualNode(ArrayNode):
        pass

    cdef cppclass LogNode(ArrayNode):
        pass

    cdef cppclass LogicalNode(ArrayNode):
        pass

    cdef cppclass MaximumNode(ArrayNode):
        pass

    cdef cppclass MaxNode(ArrayNode):
        optional[double] init

    cdef cppclass MinimumNode(ArrayNode):
        pass

    cdef cppclass MinNode(ArrayNode):
        optional[double] init

    cdef cppclass ModulusNode(ArrayNode):
        pass

    cdef cppclass MultiplyNode(ArrayNode):
        pass

    cdef cppclass NaryAddNode(ArrayNode):
        void add_node(ArrayNode*) except+

    cdef cppclass NaryMaximumNode(ArrayNode):
        void add_node(ArrayNode*) except+

    cdef cppclass NaryMinimumNode(ArrayNode):
        void add_node(ArrayNode*) except+

    cdef cppclass NaryMultiplyNode(ArrayNode):
        void add_node(ArrayNode*) except+

    cdef cppclass NegativeNode(ArrayNode):
        pass

    cdef cppclass NotNode(ArrayNode):
        pass

    cdef cppclass OrNode(ArrayNode):
        pass

    cdef cppclass PartialProdNode(ArrayNode):
        span[const Py_ssize_t] axes() const
        optional[double] init

    cdef cppclass PartialSumNode(ArrayNode):
        span[const Py_ssize_t] axes() const
        optional[double] init

    cdef cppclass ProdNode(ArrayNode):
        optional[double] init

    cdef cppclass RintNode(ArrayNode):
        pass

    cdef cppclass SafeDivideNode(ArrayNode):
        pass

    cdef cppclass SquareNode(ArrayNode):
        pass
        
    cdef cppclass SquareRootNode(ArrayNode):
        pass

    cdef cppclass SubtractNode(ArrayNode):
        pass

    cdef cppclass SumNode(ArrayNode):
        optional[double] init

    cdef cppclass XorNode(ArrayNode):
        pass


cdef extern from "dwave-optimization/nodes/numbers.hpp" namespace "dwave::optimization" nogil:
    cdef cppclass IntegerNode(ArrayNode):
        void initialize_state(State&, vector[double]) except+
        double lower_bound()
        double upper_bound()

    cdef cppclass BinaryNode(ArrayNode):
        void initialize_state(State&, vector[double]) except+


cdef extern from "dwave-optimization/nodes/quadratic_model.hpp" namespace "dwave::optimization" nogil:
    cdef cppclass QuadraticModel:
        QuadraticModel(int num_variables)
        Py_ssize_t num_variables() const
        Py_ssize_t num_interactions() const
        void add_linear(int v, double bias)
        double get_linear(int v) const

        void add_quadratic(int u, int v, double bias)
        double get_quadratic(int u, int v) const
        void get_quadratic(int* row, int* col, double* quad) const

    cdef cppclass QuadraticModelNode(ArrayNode):
        QuadraticModel* get_quadratic_model()


cdef extern from "dwave-optimization/nodes/sorting.hpp" namespace "dwave::optimization" nogil:
    cdef cppclass ArgSortNode(ArrayNode):
        pass


cdef extern from "dwave-optimization/nodes/statistics.hpp" namespace "dwave::optimization" nogil:
    cdef cppclass MeanNode(ArrayNode):
        pass


cdef extern from "dwave-optimization/nodes/testing.hpp" namespace "dwave::optimization" nogil:
    cdef cppclass ArrayValidationNode(Node):
        pass
