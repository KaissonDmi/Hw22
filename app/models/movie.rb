class Movie < ActiveRecord::Base
    @@added_ratings = []
    def self.add(rating)
        @@added_ratings << rating
    end
    
    def self.ratings
        @@added_ratings
    end
end
