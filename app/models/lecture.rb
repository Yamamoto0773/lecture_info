class Lecture < ApplicationRecord
  enum department: { general: 0, M: 1, E: 2, S: 3, J: 4, C: 5 }
end
