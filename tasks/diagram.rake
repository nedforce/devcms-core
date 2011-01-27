namespace :doc do
  namespace :diagram do
    task :models do
      sh "mkdir -p doc/diagrams"
      sh "railroad -i -l -a -m -M -o doc/diagrams/models.dot"
      sh "dot -Tpng doc/diagrams/models.dot > doc/diagrams/models.png"
    end

    task :controllers do
      sh "mkdir -p doc/diagrams"
      sh "railroad -i -l -C -o doc/diagrams/controllers.dot"
      sh "dot -Tpng doc/diagrams/controllers.dot > doc/diagrams/controllers.png"
    end

    task :aasm do
      sh "mkdir -p doc/diagrams"
      sh "railroad -i -l -A -o doc/diagrams/aasm.dot"
      sh "dot -Tpng doc/diagrams/aasm.dot > doc/diagrams/aasm.png"
    end
  end

  task :diagrams => %w(diagram:models diagram:controllers diagram:aasm)
end
