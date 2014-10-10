class Module
  def prepend?(mod)
    self.ancestors.include?(mod) && self.ancestors.index(mod) < self.ancestors.index(self)
  end
end
