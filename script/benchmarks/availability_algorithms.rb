require "benchmark"

slots = (0...2_000).to_a
blocked_slots = (0...500).step(3).to_a
blocked_lookup = blocked_slots.to_h { |slot| [slot, true] }

scan = -> { slots.reject { |slot| blocked_slots.include?(slot) } }
indexed = -> { slots.reject { |slot| blocked_lookup.key?(slot) } }

raise "algorithms disagree" unless scan.call == indexed.call

Benchmark.bmbm(12) do |benchmark|
  benchmark.report("nested scan") { 100.times { scan.call } }
  benchmark.report("indexed lookup") { 100.times { indexed.call } }
end
