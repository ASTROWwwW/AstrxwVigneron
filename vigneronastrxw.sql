-- BY ASTRXW https://discord.gg/ArxVYVfN

-- Ajouter le job 'vigneron'
INSERT INTO jobs (name, label, whitelisted) VALUES
('vigneron', 'Vigneron', 0);

-- Fix: include the `name` column; the server (grade_name=='boss') needs the top grade named 'boss'
INSERT INTO job_grades (job_name, grade, name, label, salary) VALUES
('vigneron', 0, 'recrue', 'Recrue', 200),
('vigneron', 1, 'ouvrier', 'Ouvrier', 400),
('vigneron', 2, 'chef_equipe', 'Chef d équipe', 600),
('vigneron', 3, 'manager', 'Manager', 800),
('vigneron', 4, 'boss', 'Boss', 1000);

INSERT INTO items (name, label, weight) VALUES
('raisin', 'Raisin', 1),
('vine', 'Bouteille de vin', 1);