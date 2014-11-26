# encoding:UTF-8
class Rent < ActiveRecord::Base

  belongs_to :profile  
  validates :d_from,:d_til,:name,:lastname,:email,:phone,:purpose, :presence => {}
  #validate :rent_not_during
  validate :rent_not_from  
  validate :rent_not_til  
  validate :dates
  
    def rent_not_during
      @overlap = Rent.where(confirmed: true,d_from: self.d_from..self.d_til)
      unless (@overlap.empty?) || (@overlap.first != self)
        errors.add('Datum från',' överlappar med en bokning som börjar: '+@overlap.first.d_from.to_s)
      end      
    end
    def rent_not_from
      @overlap = Rent.where(confirmed: true,d_from: self.d_from..self.d_til)
      unless (@overlap.empty?) || (@overlap.first != self)
        errors.add('"Från"',' överlappar med en bokning som börjar: '+@overlap.first.d_from.to_s)
      end      
    end
    def rent_not_til
      @overlap = Rent.where(confirmed: true,d_from: self.d_from..self.d_til)
      unless (@overlap.empty?) || (@overlap.first != self)
        errors.add('"Till"', ' överlappar med en bokning som slutar: '+@overlap.first.d_til.to_s)
      end
    end
    def dates
      #unless (self.d_from > DateTime.now)
      #  errors.add('Du kan', 'endast hyra bilen i framtiden.')
      #end        
      unless (self.d_from < self.d_til)
        errors.add('Du måste', 'lämna tillbaka bilen efter att du lånar den, inte innan.')
      end
      unless(((self.d_til-self.d_from)/3600) <= 48)
        errors.add('Du får', 'endast hyra bilen i 48h.')
      end 
    end
  
  def ical(url)
      e=Icalendar::Event.new      
      e.uid = self.id.to_json    
      e.dtstart=DateTime.civil(self.starts_at.year, self.starts_at.month, self.starts_at.day, self.starts_at.hour, self.starts_at.min)    
      e.dtend=DateTime.civil(self.ends_at.year, self.ends_at.month, self.ends_at.day, self.ends_at.hour, self.ends_at.min)
      e.location = self.location    
      e.summary=self.title
      e.description = self.category + "\n"+self.description    
      e.created=DateTime.civil(self.created_at.year, self.created_at.month, self.created_at.day, self.created_at.hour, self.created_at.min)  
      e.url = url      
      e.last_modified=DateTime.civil(self.updated_at.year, self.updated_at.month, self.updated_at.day, self.updated_at.hour, self.updated_at.min)
      e
    end 
    
    def as_json(options = {})
      if(self.confirmed) && (self.active)
        {
          :id => self.id,
          :title => self.name,        
          :start => self.d_from.rfc822,
          :end => self.d_til.rfc822,
          :url => Rails.application.routes.url_helpers.car_rent_path(id),        
          :backgroundColor => "green",
          :textColor => "black"
        }
      elsif (self.active)
        {
          :id => self.id,
          :title => self.name,        
          :start => self.d_from.rfc822,
          :end => self.d_til.rfc822,
          :url => Rails.application.routes.url_helpers.car_rent_path(id),        
          :backgroundColor => "yellow",
          :textColor => "black"
        }
       else
        {
          :id => self.id,
          :title => self.name,        
          :start => self.d_from.rfc822,
          :end => self.d_til.rfc822,
          :url => Rails.application.routes.url_helpers.car_rent_path(id),        
          :backgroundColor => "red",
          :textColor => "black"
        }
       end
    end  
end
