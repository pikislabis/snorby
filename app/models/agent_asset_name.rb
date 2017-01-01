class AgentAssetName < ActiveRecord::Base
  self.primary_keys = [:sensor_sid, :asset_name_id]

  belongs_to :sensor, foreign_key: :sensor_sid
  belongs_to :asset_name, foreign_key: :asset_name_id

  def self.delete_agent_references(ip_address, sensor_sid)
    AgentAssetName.joins(:asset_name)
                  .where(asset_names: { global: false, ip_address: ip_address },
                         sensor_sid: sensor_sid)
                  .delete_all

    # delete any empty references (global = 0 and no agents assigned)
    sql = %{
     select a.id
     from asset_names a
     left outer join agent_asset_names b on b.asset_name_id = a.id
     where a.global = 0 and a.ip_address = ?
     group by a.id
     having count(b.sensor_sid) = 0
    }

    asset_names = AssetName.find_by_sql([sql, ip_address.to_i])
    asset_names.each(&:destroy!) if asset_names
  end
end
