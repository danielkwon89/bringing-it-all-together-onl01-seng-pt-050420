require 'pry'

class Dog
    attr_accessor :name, :breed, :id

    def initialize(name:, breed:, id: nil)
        @name, @breed, @id = name, breed, id
    end

    def self.create_table
        DB[:conn].execute("CREATE TABLE dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end

    def save
        DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(attr_hash)
        dog = self.new(attr_hash)
        dog.save
    end

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end
    
    def self.find_by_id(num)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", num).flatten
        self.new_from_db(dog)
    end

    def self.find_or_create_by(arg)
        var = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", arg[:name], arg[:breed]).flatten
        var.empty? ? self.create(arg) : self.new(id: var[0], name: var[1], breed: var[2])
    end
    
    def self.find_by_name(name)
        var = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).flatten
        self.new(id: var[0], name: var[1], breed: var[2])
    end

    def update
        DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
    end

end