class RelationController < ApplicationController
  # before_filter :login_required if $conf[:authenticate]
  caches_action :list

  def list
   @s_relations = SRelation.find(:all)
   sr_hash = {}
   keys = []
   @s_relations.each do |sr|
     keys = sr.nature.split(/(_AND_|_OR_)/)
     keys << sr.nature if keys.length > 1
     #keys = sr.nature.split(/(_DOESNOTSPLIT_)/)
     keys.each do |key|
       next if /\A_.*_\z/ =~ key
       if sr_hash[key]
         sr_hash[key] << sr
       else
         sr_hash[key] = [sr]
       end
     end
   end
   @sr_array = sr_hash.sort_by{|key,value|[-value.inject(0){|r,i|r += i.relations.size}, key]}
  end

  def show
  end
  
  def specify
    relations = []
    if params[:id]
      params[:id].split('-').each do |i|
        relations += SRelation.find(i).relations
      end
    end
    r_hash = {}
    relations.each do |r|
      key = r.source.s_frame.form + " " + r.nature + " " + r.target.s_frame.form
      if r_hash[key]
        r_hash[key] << r
      else
        r_hash[key] = [r]
      end
    end
    @r_array = r_hash.sort_by{|key, value|[-value.size, value[0].nature, key]}
    nature = relations.collect(&:nature).uniq
    if nature.size > 1
      @nature = '{' + nature.join(', ') + '}'
    else
      @nature = nature.first
    end
  end
  
  private
end
