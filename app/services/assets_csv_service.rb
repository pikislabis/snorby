class AssetsCsvService
  def initialize(csv, overwrite = false)
    @csv = csv
    @overwrite = overwrite
  end

  def upload
    errors = []
    line_number = 0

    @csv.lines.each do |line|
      line_number += 1
      line = line.strip
      next unless line && !line.empty?

      items = line.split(',')

      unless items.length >= 2
        errors.push(line_number, "Incorrect format: #{line}")
        next
      end

      ip_address = (items[0] || '').strip
      name = (items[1] || '').strip
      global = true
      sensor_name = nil

      unless ip_address && name
        errors.push(line_number, "Incorrect format (IP and name required): #{line}")
        next
      end

      if items.length > 2
        sensor_name = items[2].strip
        global = false unless sensor_name.empty?
      end

      begin
        ip = IPAddr.new(ip_address, Socket::AF_INET)
      rescue
        errors.push(line_number, "Invalid IP: #{ip_address}")
        next
      end

      if global

        # if there's already a global name for ip_address
        existing_name = AssetName.find_by(ip_address: ip.to_i, global: true)

        if existing_name
          if @overwrite
            existing_name.name = name
            existing_name.save!
          else
            errors.push(line_number, "#{ip.to_s} already has a global definition")
          end
        else
          asset_name = AssetName.new(ip_address: ip, name: name, global: true)
          unless asset_name.save
            errors.push(line_number, "Error saving: #{items}, #{asset_name.errors.join(',')}")
          end
        end
      else

        sensor = Sensor.find_by(hostname: sensor_name) || Sensor.find_by(name: sensor_name)

        unless sensor
          errors.push(line_number, "#{sensor_name} has no matching sensor")
          next
        end

        # look for a sensor match
        sql = %(
         select id, name, ip_address, global
         from asset_names a
         inner join agent_asset_names b on b.asset_name_id = a.id
         where global = 0 and ip_address = ? and sensor_sid = ?
        )

        matched_assets = AssetName.find_by_sql([sql, ip.to_i, sensor.sid])

        if matched_assets && !matched_assets.empty? && !@overwrite
          errors.push(line_number, "#{ip} #{sensor.hostname} already has a definition")
          next
        end

        if matched_assets
          AgentAssetName.delete_agent_references(ip.to_i, sensor.sid)
        end

        # look for a non-global entry with that name.
        asset_name = AssetName.find_or_create_by(
          ip_address: ip, global: false, name: name
        )

        asset_name.sensors.push(sensor)

        asset_name.save!
        unless asset_name.save!
          errors.push(line_number, "Error saving: #{items}, #{asset_name.errors.join(',')}")
        end
      end
    end

    errors
  end
end
