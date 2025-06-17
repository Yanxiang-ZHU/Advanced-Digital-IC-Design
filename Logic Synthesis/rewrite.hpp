#pragma once

#include <mockturtle/algorithms/cut_rewriting.hpp>
#include <mockturtle/algorithms/node_resynthesis/akers.hpp>
#include <mockturtle/algorithms/node_resynthesis/exact.hpp>
#include <mockturtle/networks/aig.hpp>
#include <mockturtle/properties/mccost.hpp>
#include <mockturtle/traits.hpp>
#include <mockturtle/utils/cost_functions.hpp>
#include <mockturtle/views/fanout_view.hpp>
#include <mockturtle/algorithms/node_resynthesis/xag_npn.hpp>


using namespace percy;
using namespace mockturtle;

namespace phyLS
{
template <class Ntk>
void aig_rewrite(Ntk& ntk) {

  xag_npn_resynthesis<aig_network, aig_network, xag_npn_db_kind::aig_complete> resyn;
  const auto before = ntk.num_gates();
  cut_rewriting_params ps;
  ps.cut_enumeration_ps.cut_size = 4;
  ps.min_cand_cut_size = 2;
  ps.min_cand_cut_size_override = 3;
  cut_rewriting_with_compatibility_graph( ntk, resyn, ps );
  ntk = cleanup_dangling( ntk );
}
}