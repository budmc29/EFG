# This is intended to provide a mechanism by which relatively expensive data
# updates can be decoupled from deployment time and run independently.
#
# This will execute within an ActiveRecord transaction and is instance_eval-ed.
# Just write normal ruby code and refer to any model objects that you require.
# Since a data migration is intended to be run in production, when the schema
# and model are known quantities, it should be fine to reference model classes
# directly, even though in the future they may be refactored or deleted
# entirely.

phase_7_lending_limit_ids = [595, 596, 597, 598, 599, 600, 601, 602, 603, 604,
                             605, 606, 607, 608, 609, 610, 611, 612, 613, 614,
                             615, 616, 617, 618, 619, 620, 621, 622, 623, 624,
                             625, 626, 627, 628, 629, 630, 631, 632, 633, 634,
                             635, 636, 637, 638]

LendingLimit.where(id: phase_7_lending_limit_ids).update_all(phase_id: 7)
