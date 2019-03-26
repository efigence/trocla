class Trocla::Formats::Ssh < Trocla::Formats::Base
  require 'tmpdir'
  require 'open3'
  def format(plain_password,options={})
    keytype = options['type'] ||'rsa'
    keybits = options['bits'] || false
    keycomment = options['comment'] || "trocla"
    if keybits
      keybits = keybits.to_i
      if keybits < 256 || (keytype == 'rsa' && keybits < 1024)
          raise "too small keybits size; refer to ssh-keygen manual to see supported ones"
      end
    end
    priv_key = ""
    pub_key = ""
    Dir.mktmpdir do |dir|
      if keybits
        keygen_cmd = ['ssh-keygen', '-P','','-f', dir + '/key', '-C', keycomment,"-b", keybits]
      else
        keygen_cmd = ['ssh-keygen', '-P','','-f', dir + '/key', '-C', keycomment]
      end
      puts keygen_cmd
      out, status = Open3.capture2e(
          *keygen_cmd,
      )
      priv_key = File.read(dir + "/key")
      pub_key =  File.read(dir + "/key.pub")
    end
    if (!priv_key.include?('PRIVATE'))
      raise "something went wrong with privkey generation [#{priv_key}], ssh-keygen out: #{out}"
    end
    if (!pub_key.include?('ssh-'))
      raise "something went wrong with pubkey generation [#{pib_key}], ssh-keygen out: #{out}"
    end
    keydata = {
        "priv" => priv_key.chomp,
        "pub" => pub_key.chomp,
        "type" => keytype,
    }
    if keybits
      keydata['bits'] = keybits
    end

    return keydata
  end
  def render(output,render_options={})
    if render_options["priv"]
      output['priv']
    elsif render_options["pub"]
      output['pub']
    else
      super(output,render_options)
    end
  end

end
