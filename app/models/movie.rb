class Movie < ActiveRecord::Base
    @@all_ratings = ['G','PG','PG-13','R', 'NC-17']
    @@added_ratings = []
    @@sort = "normal"
    @@current_movies = []
    @@first = true
    
    
    def self.sort_type
        return @@sort
    end
    
    def self.set_sort(num)
        @@sort = num
    end
    
    def self.add(rating)
        if !rating.in?(@@added_ratings)
            @@added_ratings << rating
        end
    end
    
    def self.remove(rating)
        if rating.in?(@@added_ratings)
            @@added_ratings.delete(rating)
        end
    end
    
    def self.movies_to_show (params)
        if @@first 
            @@first = false
            @@current_movies = Movie.fil(Movie.alls)
            return @@current_movies
        end
        
        if !@@first and !params.key?("ratings") and !params.key?("id")
            @@added_ratings = []
            @@current_movies = Movie.fil(Movie.alls)
            case @@sort
            when "alph"
                @@current_movies = Movie.alphabet_sort
            when "date"
                @@current_movies = Movie.date_sort
            end
            return @@current_movies
        end    
        if params[:id] == "tit_head"
            @@current_movies = Movie.alphabet_sort
            @@sort = "alph"
            return @@current_movies
        end
        
        if params[:id] == "dat_head"
            @@current_movies = Movie.date_sort
            @@sort = "date"
            return @@current_movies
        end
        
        if params.key?("ratings") 
            new_ratings = []
            Movie.alls.each do |rating|
                if params["ratings"].key?(rating)
                    new_ratings << rating
                end
            end
            @@added_ratings = new_ratings
            @@current_movies = Movie.filter
            case @@sort
            when "alph"
                @@current_movies = Movie.alphabet_sort
            when "date"
                @@current_movies = Movie.date_sort
            end
            return @@current_movies
        end
            
            
    end
    
    def self.from_cookie(hash, params)
        if @@first
            return Movie.movies_to_show(params)
        end
        list = Movie.fil (hash["ratings"])
        @@added_ratings = hash["ratings"]
        @@current_movies = list
        
        if hash["sort"] == "normal"
            return @@current_movies
        elsif hash["sort"] == "alph"
            @@current_movies = Movie.alphabet_sort
            return @@current_movies
        else 
            @@current_movies = Movie.date_sort
            return @@current_movies
        end
    end
    
    def self.filter
        returning = []
        Movie.all.each do |film|
            if film.rating.in?(@@added_ratings)
                returning << film
            end
        end
        returning
    end
    
     def self.fil (rates)
        returning = []
        Movie.all.each do |film|
            if film.rating.in?(rates)
                returning << film
            end
        end
        returning
    end
    
    def self.date_sort
        films = @@current_movies
        returning = []
        films.each do |film|
            if returning.length() == 0
                returning << film
            else
                i = 0
                inserted = false
                while i < returning.length()
                    if film.date_int <= returning[i].date_int
                        returning.insert(i, film)
                        inserted = true
                        break
                    end
                    i += 1
                end
                if !inserted
                    returning << film #if it's the latest date
                end
            end
        end
        return returning
    end
    
    def self.alphabet_sort
        films = @@current_movies
        returning = []
        symboltitles = []
        symbols = "!@#$%^&*()<>?/[]';:'~"
        nums = []
        digits = "0123456789"
        
        
        films.each do |film|
            if film.title.length() > 0 and film.title[0].in?(symbols)
                symboltitles << film
                next
            end
            
            if film.title.length() > 0 and film.title[0].in?(digits)
                if nums.length() < 1
                    nums << film
                else
                    i = 0
                    inserted = false
                    while i < nums.length()
                        if film.title[0].to_i <= nums[i].title[0].to_i
                            nums.insert(i, film)
                            inserted = true
                            break
                        end
                        i += 1
                    end
                    if !inserted
                            nums << film
                    end
                end
                
                next
            end
            
            if returning.length() == 0
                returning << film
            else
                i = 0
                inserted = false
                while i < returning.length()
                    thing = film.title .casecmp returning[i].title
                    if thing == -1 or thing == 0
                        returning.insert(i, film)
                        inserted = true
                        break
                    end
                    i += 1
                end
                if !inserted
                    returning << film #if it's the latest date
                end
            end
        end
        returning.concat(nums)
        returning.concat(symboltitles)
        return returning
    end
    
    def self.ratings
        @@added_ratings
    end
    
    def self.alls
        @@all_ratings
    end
    
    def self.title_status
        if @@sort == "alph"
            return true
        else
            return false
        end
    end
    
    def self.date_status
        if @@sort == "date"
            return true
        else
            return false
        end
    end
    def date_int
        date = self.release_date.year.to_s
        if self.release_date.month.to_s.length() < 2
            date += '0'
        end
        date += self.release_date.month.to_s
        
        if self.release_date.day.to_s.length() < 2
            date += '0'
        end
        date += self.release_date.day.to_s   
        
        return date.to_i
    end
end
