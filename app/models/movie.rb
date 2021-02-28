class Movie < ActiveRecord::Base
    @@all_ratings = ['G','PG','PG-13','R']
    @@added_ratings = []
    def self.add(rating)
        @@added_ratings << rating
    end
    
    def self.ratings
        @@added_ratings
    end
    
    def self.alls
        @@all_ratings
    end
end
