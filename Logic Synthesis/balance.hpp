#pragma once

#include <mockturtle/algorithms/balancing.hpp>
#include <mockturtle/algorithms/balancing/sop_balancing.hpp>
#include <mockturtle/networks/aig.hpp>
#include <mockturtle/views/depth_view.hpp>

namespace phyLS {

template <class Ntk>
void aig_balancing(Ntk& ntk)
{
    mockturtle::balancing_params ps;
    ps.cut_enumeration_ps.cut_size = 4;

    mockturtle::sop_rebalancing<Ntk> rebalancer;
    mockturtle::rebalancing_function_t<Ntk> rebalancing_fn = [&](Ntk& dest,
        const kitty::dynamic_truth_table& function,
        const std::vector<mockturtle::arrival_time_pair<Ntk>>& children,
        uint32_t best_level,
        uint32_t best_cost,
        const mockturtle::rebalancing_function_callback_t<Ntk>& callback) {

        rebalancer(dest, function, children, best_level, best_cost, callback);
    };

    ntk = mockturtle::balancing(ntk, rebalancing_fn, ps);
    ntk = mockturtle::cleanup_dangling(ntk);
}

}