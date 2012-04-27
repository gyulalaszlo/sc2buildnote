#
# Mineral income was measured by running SCVs for 3 minutes and 
# writing down resources mined in the 1st, 2nd, and 3rd minute.
#
# 4a) Closest mineral patch, SCVs vs income
# - 1 SCV: Measured 45min/minute (predicted 45min/m)
# - 2 SCVs: Measured 90min/minute (predicted 90min/m)
# - 3 SCVs: Measured 100-105min/minute (predicted 102min/m)

# 4b) Furthest mineral patch, SCVs vs income
# - 1 SCV: Measured 35-40 min/minute (predicted 39min/m)
# - 2 SCVs: Measured 75-80min/minute (predicted 78min/m)
# - 3 SCVs: Measured 100-105min/minute (predicted 102min/m)

# Gas income was measured more easily (I got tired)
# by timing the time spent obtaining 40 gas for
# 1 scv, 80 gas for 2 scvs, and 120 for 3-4 scvs.
# This was used to estimate the number of seconds
# per gas packet returned.

# 4c) Close gas geyser, SCVs vs income
# - 1 SCV: Measured 6.3 seconds/packet (predicted 6.3s)
# - 2 SCVs: Measured 2.9 seconds/packet (predicted 3.1s)
# - 3 SCVs: Measured 2.1 seconds/packet (predicted 2.1s)
# - 4 SCVs: Measured 2.1 seconds/packet (predicted 2.1s)

# 4d) Far gas geyser, SCVs vs income
# - 1 SCV: Measured 7.1 seconds/packet (predicted 7.1s)
# - 2 SCVs: Measured 3.7 seconds/packet (predicted 3.6s)
# - 3 SCVs: Measured 2.4 seconds/packet (predicted 2.4s)
# - 4 SCVs: Measured 2.1 seconds/packet (predicted 2.1s)
#

# all patches close
# MINING_PER_MINUTE = [ 0, 45, 90, 102 ]

# middle of the road patches
MINING_PER_MINUTE = [ 0, 40, 80, 100 ]

MINING_RATES = _( MINING_PER_MINUTE ).map (e)-> e / 60.0


class MiningReactor

  constructor: (@game_reactor)->
    @patches = 8
    @last_mined = new Cost 0, 0, 0


  # process the mining
  mine: (workers, resources)->
    worker_count = workers.length
    # filter the 0 workers case
    return if worker_count == 0

    # get minimum and maximum workers per patch
    max_workers_per_patch = Math.ceil( worker_count / @patches )
    min_workers_per_patch = Math.max( 0, max_workers_per_patch - 1)

    patches_with_max_workers = worker_count % @patches
    # if the worker count is an integer multiple of the number of patches
    # we need to manually set the patch count, as we have already
    # filtered out the case of 0 workers
    patches_with_max_workers = @patches if patches_with_max_workers == 0
    patches_with_min_workers = @patches - patches_with_max_workers

    # calculate the income
    income =
      patches_with_max_workers * MINING_RATES[ max_workers_per_patch ] +
      patches_with_min_workers * MINING_RATES[ min_workers_per_patch ]

    # set the cached Cost object to the income
    @last_mined.set income
    resources.add @last_mined

    @log "#{worker_count} workers [#{patches_with_max_workers}x#{max_workers_per_patch} W + #{patches_with_min_workers}x#{min_workers_per_patch} W] mined: ", @last_mined.toString()



  log: (message...)-> console.log "[MiningReactor] ", message...

  error: (message...)-> console.error "[MiningReactor] ", message...






exp = exports ? this
exp.MiningReactor = MiningReactor

